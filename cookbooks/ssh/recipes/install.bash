#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'openssh-server'
}

function install()
{
    local i=0

    for ((i = 0; i < ${#SSH_CONFIGS[@]}; i = i + 2))
    do
        header "ADDING SSH CONFIG '${SSH_CONFIGS[${i} + 1]}'"

        appendToFileIfNotFound '/etc/ssh/sshd_config' "${SSH_CONFIGS[${i}]}" "${SSH_CONFIGS[${i} + 1]}" 'true' 'false' 'false'
    done

    header 'RESTARTING SSH SERVICE'

    service ssh restart
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SSH'

    installDependencies
    install
    installCleanUp
}

main "${@}"