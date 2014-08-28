#!/bin/bash -e

function install()
{
    local users="${@}"

    users+=" $(whoami)"

    local user=''

    for user in ${users}
    do
        local profileFile="$(getProfileFile "${user}")"

        if [[ "$(isEmptyString "${profileFile}")" = 'false' ]]
        then
            if [[ "$(whoami)" = "${user}" ]]
            then
                local prompt="export PS1=\"${ps1RootPrompt}\""
            else
                local prompt="export PS1=\"${ps1UserPrompt}\""
            fi

            echo -e "Updating '\033[1;32m${profileFile}\033[0m'"

            if [[ ! -f "${profileFile}" ]]
            then
                touch "${profileFile}"
                chown "${user}":"${user}" "${profileFile}"
            fi

            appendToFileIfNotFound "${profileFile}" "${prompt}" "${prompt}" 'false' 'false'
        else
            warn "WARN : home directory of user '${user}' not found!"
        fi
    done
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PS1'

    install "${@}"
    installCleanUp
}

main "${@}"