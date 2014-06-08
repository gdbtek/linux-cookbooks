#!/bin/bash

function install()
{
    local users="${@}"

    if [[ "$(isEmptyString "${users}")" = 'true' ]]
    then
        users="$(whoami)"
    fi

    local user=''

    for user in ${users}
    do
        local profileFile="$(getProfileFile "${user}")"

        if [[ "$(isEmptyString "${profileFile}")" = 'false' ]]
        then
            if [[ "$(whoami)" = "${user}" ]]
            then
                local prompt="export PS1=\"${rootPrompt}\""
            else
                local prompt="export PS1=\"${userPrompt}\""
            fi

            echo -e "Updating '\033[1;32m${profileFile}\033[0m'"

            touch "${profileFile}"
            appendToFileIfNotFound "${profileFile}" "${prompt}" "${prompt}" 'false' 'false'
        else
            warn "WARN: user '${user}' not found!"
        fi
    done
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING PS1'

    checkRequireRootUser

    install "${@}"
    installCleanUp
}

main "${@}"
