#!/bin/bash -e

##################
# IMPLEMENTATION #
##################

function displayUsage()
{
    local -r scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e '\033[1;33m'
    echo    'SYNOPSIS :'
    echo    "  ${scriptName}"
    echo    '    --help'
    echo    '    --user            <USER>'
    echo    '    --token           <TOKEN>'
    echo    '    --clone-folder    <CLONE_FOLDER>'
    echo -e '\033[1;35m'
    echo    'DESCRIPTION :'
    echo    '  --help            Help page (optional)'
    echo    '  --user            User name (require)'
    echo    '  --token           Personal access token (require)'
    echo    '  --clone-folder    Folder path to clone all repositories to (require)'
    echo -e '\033[1;36m'
    echo    'EXAMPLES :'
    echo    "  ./${scriptName} --help"
    echo    "  ./${scriptName} --user 'gdbtek' --token 'a5hb5ds1cfq0d1p8brgmspnogdib9hfn7kcy2xaf' --clone-folder='/path/to/folder'"

    echo -e '\033[0m'

    exit "${1}"
}

function cloneAllUserRepositories()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r cloneFolder="${3}"
    local -r visibility="${4}"
    local -r repositorySSHURLs=(${5})

    checkNonEmptyString "${user}" 'undefined user'
    checkNonEmptyString "${token}" 'undefined token'
    checkExistFolder "${cloneFolder}"

    # Get User Details

    local -r gitUserPrimaryEmail="$(getGitUserPrimaryEmail "${user}" "${token}")"
    local -r gitUserName="$(getGitUserName "${user}" "${token}")"

    checkNonEmptyString "${gitUserPrimaryEmail}" 'undefined git user primary email'
    checkNonEmptyString "${gitUserName}" 'undefined git user name'

    # Create User Folder

    local -r rootRepository="${cloneFolder}/${user}/${visibility}"

    mkdir -p "${rootRepository}"

    # Each Repository

    local repositorySSHURL=''

    for repositorySSHURL in "${repositorySSHURLs[@]}"
    do
        header "CLONING '${repositorySSHURL}' IN '${rootRepository}'"

        # Clone Repository

        cd "${rootRepository}"
        git clone "${repositorySSHURL}"

        # Config Git

        cd "$(getGitRepositoryNameFromCloneURL "${repositorySSHURL}")"

        git config user.email "${gitUserPrimaryEmail}"
        git config user.name "${gitUserName}"

        info "\n$(git config --list)"
    done
}

########
# MAIN #
########

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    # Parsing Command Arguments

    local -r optCount="${#}"

    while [[ "${#}" -gt '0' ]]
    do
        case "${1}" in
            --help)
                displayUsage 0
                ;;

            --user)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local user="${1}"
                fi

                ;;

            --token)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local token="${1}"
                fi

                ;;

            --clone-folder)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local cloneFolder="${1}"
                fi

                ;;

            *)
                shift
                ;;
        esac
    done

    # Validate Opt

    if [[ "${optCount}" -lt '1' ]]
    then
        displayUsage 0
    fi

    # Clone Repositories

    cloneAllUserRepositories "${user}" "${token}" "${cloneFolder}" 'private' "$(getGitUserPrivateRepositorySSHURL "${user}" "${token}")"
    cloneAllUserRepositories "${user}" "${token}" "${cloneFolder}" 'public' "$(getGitUserPublicRepositorySSHURL "${user}" "${token}")"
}

main "${@}"