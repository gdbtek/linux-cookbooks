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
    echo    '    --clone-depth     <CLONE_DEPTH>'
    echo    '    --clone-folder    <CLONE_FOLDER>'
    echo    '    --git-url         <GIT_URL>'
    echo    '    --org-name        <ORGANIZATION_NAME>'
    echo -e '\033[1;35m'
    echo    'DESCRIPTION :'
    echo    '  --help            Help page (optional)'
    echo    '  --user            User name (require)'
    echo    '  --token           Personal access token (require)'
    echo    '  --clone-depth     How deep your clone should go (optional)'
    echo    '  --clone-folder    Folder path to clone all repositories to (optional)'
    echo    '                    Default to current working directory path'
    echo    '  --git-url         Git URL (optional)'
    echo    "                    Default to 'https://api.github.com'"
    echo    '  --org-name        Organization name (optional)'
    echo -e '\033[1;36m'
    echo    'EXAMPLES :'
    echo    "  ./${scriptName} --help"
    echo    "  ./${scriptName} --user 'user-name' --token 'a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9'"
    echo    "  ./${scriptName} --user 'user-name' --token 'a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9' --clone-folder '/path/to/folder'"
    echo    "  ./${scriptName} --user 'user-name' --token 'a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9' --clone-folder '/path/to/folder' --clone-depth '1' --org-name 'my-org'"
    echo    "  ./${scriptName} --user 'user-name' --token 'a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9' --clone-folder '/path/to/folder' --org-name 'my-org' --git-url 'https://my.git.com/api/v3'"

    echo -e '\033[0m'

    exit "${1}"
}

function cloneAllRepositories()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r cloneDepth="${3}"
    local -r cloneFolder="${4}"
    local -r gitURL="${5}"
    local -r orgName="${6}"
    local -r kind="${7}"

    # Validation

    checkNonEmptyString "${user}" 'undefined user'
    checkNonEmptyString "${token}" 'undefined token'
    checkExistFolder "${cloneFolder}"

    # Get User Details

    local -r gitUserPrimaryEmail="$(getGitUserPrimaryEmail "${user}" "${token}" "${gitURL}")"
    local -r gitUserName="$(getGitUserName "${user}" "${token}" "${gitURL}")"

    checkNonEmptyString "${gitUserPrimaryEmail}" 'undefined git user primary email'
    checkNonEmptyString "${gitUserName}" 'undefined git user name'

    # Create Root Folder

    if [[ "$(isEmptyString "${orgName}")" = 'true' ]]
    then
        local -r rootRepository="${cloneFolder}/$(tr '[:upper:]' '[:lower:]' <<< "${user}")/${kind}"
    else
        local -r rootRepository="${cloneFolder}/$(tr '[:upper:]' '[:lower:]' <<< "${orgName}")/${kind}"
    fi

    mkdir -p "${rootRepository}"

    # Each Repository

    if [[ "${kind}" = 'public' ]]
    then
        local -r repositorySSHURLs=($(getGitPublicRepositorySSHURL "${user}" "${token}" "${orgName}" "${gitURL}"))
    elif [[ "${kind}" = 'private' ]]
    then
        local -r repositorySSHURLs=($(getGitPrivateRepositorySSHURL "${user}" "${token}" "${orgName}" "${gitURL}"))
    else
        local -r repositorySSHURLs=()
    fi

    local repositorySSHURL=''

    for repositorySSHURL in "${repositorySSHURLs[@]}"
    do
        header "CLONING '${repositorySSHURL}' IN '${rootRepository}'"

        # Clone Repository

        cd "${rootRepository}"

        if [[ "$(isEmptyString "${cloneDepth}")" = 'true' ]]
        then
            git clone "${repositorySSHURL}"
        else
            checkPositiveInteger "${cloneDepth}"
            git clone --depth "${cloneDepth}" "${repositorySSHURL}"
        fi

        # Config Git

        cd "$(getGitRepositoryNameFromCloneURL "${repositorySSHURL}")"

        if [[ "$(isEmptyString "${gitUserPrimaryEmail}")" = 'false' ]]
        then
            git config user.email "${gitUserPrimaryEmail}"
        fi

        if [[ "$(isEmptyString "${gitUserName}")" = 'false' ]]
        then
            git config user.name "${gitUserName}"
        fi

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

            --clone-depth)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local cloneDepth="${1}"
                fi

                ;;

            --clone-folder)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local cloneFolder="${1}"
                fi

                ;;

            --git-url)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local gitURL="${1}"
                fi

                ;;

            --org-name)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local orgName="${1}"
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

    # Default Values

    if [[ "$(isEmptyString "${cloneFolder}")" = 'true' ]]
    then
        cloneFolder="$(pwd)"
    fi

    # Clone Repositories

    cloneAllRepositories "${user}" "${token}" "${cloneDepth}" "${cloneFolder}" "${gitURL}" "${orgName}" 'private'
    cloneAllRepositories "${user}" "${token}" "${cloneDepth}" "${cloneFolder}" "${gitURL}" "${orgName}" 'public'
}

main "${@}"