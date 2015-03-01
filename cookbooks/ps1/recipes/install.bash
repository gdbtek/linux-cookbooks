#!/bin/bash -e

function displayUsage()
{
    local scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e "\033[1;33m"
    echo    "SYNOPSIS :"
    echo    "    ${scriptName}"
    echo    "        --help"
    echo    "        --host-name    <HOST_NAME>"
    echo    "        --users        <USERS>"
    echo -e "\033[1;35m"
    echo    "DESCRIPTION :"
    echo    "    --help         Help page"
    echo    "    --host-name    Custom host name (optional). Default to current host name"
    echo    "    --users        List of users separated by commas or spaces (optional). Default to current user"
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
    echo -e "\033[0m"

    exit "${1}"
}

function install()
{
    local hostName="${1}"
    local users=(${2//,/ })

    # Reformat PS1

    if [[ "$(isEmptyString "${hostName}")" = 'false' ]]
    then
        ps1RootPrompt="$(replaceString "${ps1RootPrompt}" '\\h' "${hostName}")"
        ps1UserPrompt="$(replaceString "${ps1UserPrompt}" '\\h' "${hostName}")"
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
        local profileFilePath="$(getProfileFilePath "${user}")"

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

            appendToFileIfNotFound "${profileFilePath}" "${prompt}" "${prompt}" 'false' 'false' 'true'
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

    install "${hostName}" "${users}"
    installCleanUp
}

main "${@}"