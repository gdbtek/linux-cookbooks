#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'openssh-server'
}

function install()
{
    local config=''

    for config in "${SSH_CONFIGS[@]}"
    do
        header "ADDING SSH CONFIG '${config}'"
        appendToFileIfNotFound '/etc/ssh/sshd_config' "$(stringToSearchPattern "${config}")" "${config}" 'true' 'false' 'true'
    done

    header 'RESTARTING SSH SERVICE'
    service ssh restart

    if [[ "$(isPortOpen '22')" = 'false' ]]
    then
        fatal '\nFATAL : ssh service start failed'
    fi
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