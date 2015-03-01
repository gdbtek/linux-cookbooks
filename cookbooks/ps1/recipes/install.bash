#!/bin/bash -e

function displayUsage()
{
    local scriptName="$(basename "${BASH_SOURCE[0]}")"

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
    echo    "        --host-name 'my-server.com'"
    echo    "        --users 'user1 user2 user3'"
    echo    "        --profile-file-name '.bash_profile'"
    echo -e "\033[0m"

    exit "${1}"
}

function install()
{
    local profileFileName="${1}"
    local hostName="${2}"
    local users=(${3//,/ } "$(whoami)")

    # Reformat PS1

    if [[ "$(isEmptyString "${hostName}")" = 'false' ]]
    then
        ps1RootPrompt="$(replaceString "${ps1RootPrompt}" '\\h' "${hostName}")"
        ps1UserPrompt="$(replaceString "${ps1UserPrompt}" '\\h' "${hostName}")"
    fi

    # Update Prompt

    local user=''

    for user in "${users[@]}"
    do
        local profileFilePath="$(getUserHomeFolder "${user}")/${profileFileName}"

        if [[ "$(isEmptyString "${profileFilePath}")" = 'false' ]]
        then
            local profileFilePath="$(getProfileFile "${user}")"
        fi

        if [[ "$(isEmptyString "${profileFilePath}")" = 'false' ]]
        then
            if [[ "$(whoami)" = "${user}" ]]
            then
                local prompt="export PS1=\"${ps1RootPrompt}\""
            else
                local prompt="export PS1=\"${ps1UserPrompt}\""
            fi

            echo -e "Updating '\033[1;32m${profileFilePath}\033[0m'"

            if [[ ! -f "${profileFilePath}" ]]
            then
                touch "${profileFilePath}"
                chown "${user}:${user}" "${profileFilePath}"
            fi

            appendToFileIfNotFound "${profileFile}" "${prompt}" "${prompt}" 'false' 'false' 'true'
        else
            warn "WARN : profile '${user}' not found"
        fi
    done
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

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
                    local profileFileName="$(trimString "${1}")"
                fi

                ;;

            --host-name)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local hostName="$(trimString "${1}")"
                fi

                ;;

            --users)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local users="$(trimString "${1}")"
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

    install "${profileFileName}" "${hostName}" "${users}"
    installCleanUp
}

main "${@}"