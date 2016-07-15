#!/bin/bash -e

function displayUsage()
{
    local -r scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e "\033[1;33m"
    echo    "SYNOPSIS :"
    echo    "    ${scriptName}"
    echo    "        --help"
    echo    "        --profile-file-name    <PROFILE_FILE_NAME>"
    echo    "        --host-name            <HOST_NAME>"
    echo    "        --users                <USERS>"
    echo -e "\033[1;35m"
    echo    "DESCRIPTION :"
    echo    "    --help                 Help page"
    echo    "    --profile-file-name    Profile file name such as '.profile', '.bash_profile', '.bashrc' (optional)"
    echo    "    --host-name            Custom host name (optional). Default to current host name"
    echo    "    --users                List of users separated by commas or spaces (optional). Default to current user"
    echo -e "\033[1;36m"
    echo    "EXAMPLES :"
    echo    "    ./${scriptName} --help"
    echo    "    ./${scriptName}"
    echo    "    ./${scriptName}"
    echo    "        --users 'user1, user2, user3'"
    echo    "    ./${scriptName}"
    echo    "        --host-name 'my-server.com'"
    echo    "    ./${scriptName}"
    echo    "        --host-name 'my-server.com'"
    echo    "        --users 'user1 user2 user3'"
    echo    "    ./${scriptName}"
    echo    "        --profile-file-name '.bash_profile'"
    echo    "        --host-name 'my-server.com'"
    echo    "        --users 'user1 user2 user3'"
    echo -e "\033[0m"

    exit "${1}"
}

function install()
{
    local -r profileFileName="${1}"
    local -r hostName="${2}"
    local users=(${3//,/ })

    # Reformat PS1

    if [[ "$(isEmptyString "${hostName}")" = 'false' ]]
    then
        PS1_ROOT_PROMPT="$(replaceString "${PS1_ROOT_PROMPT}" '\\h' "${hostName}")"
        PS1_USER_PROMPT="$(replaceString "${PS1_USER_PROMPT}" '\\h' "${hostName}")"
    fi

    # Add Current User To List When Array Is Empty

    if [[ "${#users[@]}" -lt '1' ]]
    then
        users=("$(whoami)")
    fi

    # Update Prompt

    local user=''

    for user in "${users[@]}"
    do
        # Use Auto Detect Profile File Path Or Use Specified Profile File Name

        local profileFilePath
        profileFilePath="$(getProfileFilePath "${user}")"

        if [[ "$(isEmptyString "${profileFileName}")" = 'false' ]]
        then
            profileFilePath="$(getUserHomeFolder "${user}")/${profileFileName}"
        fi

        # Update Profile File Path

        if [[ "$(isEmptyString "${profileFilePath}")" = 'false' ]]
        then
            if [[ "$(whoami)" = "${user}" ]]
            then
                local prompt="export PS1=\"${PS1_ROOT_PROMPT}\""
            else
                local prompt="export PS1=\"${PS1_USER_PROMPT}\""
            fi

            echo -e "Updating '\033[1;32m${profileFilePath}\033[0m'"

            if [[ ! -f "${profileFilePath}" ]]
            then
                touch "${profileFilePath}"
                chown "${user}:${user}" "${profileFilePath}"
            fi

            appendToFileIfNotFound "${profileFilePath}" "${prompt}" "${prompt}" 'false' 'false' 'true'
        else
            warn "WARN : profile '${user}' not found"
        fi
    done

    # Update Default Prompt

    local -r defaultPrompt="export PS1=\"${PS1_USER_PROMPT}\""
    local -r defaultProfileFilePath='/etc/skel/.profile'

    echo -e "Updating '\033[1;32m${defaultProfileFilePath}\033[0m'"

    appendToFileIfNotFound "${defaultProfileFilePath}" "${defaultPrompt}" "${defaultPrompt}" 'false' 'false' 'true'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    while [[ "${#}" -gt '0' ]]
    do
        case "${1}" in
            --help)
                displayUsage 0
                ;;

            --profile-file-name)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local -r profileFileName="$(trimString "${1}")"
                fi

                ;;

            --host-name)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local -r hostName="$(trimString "${1}")"
                fi

                ;;

            --users)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    # shellcheck disable=SC2178
                    local -r users="$(trimString "${1}")"
                fi

                ;;

            *)
                shift
                ;;
        esac
    done

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PS1'

    # shellcheck disable=SC2128
    install "${profileFileName}" "${hostName}" "${users}"

    installCleanUp
}

main "${@}"