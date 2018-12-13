#!/bin/bash -e

function installDependencies()
{
    installPackages 'openssh-server'
}

function install()
{
    umask '0022'

    # Configure

    local config=''

    for config in "${SSH_CONFIGS[@]}"
    do
        header "ADDING SSH CONFIG '${config}'"
        appendToFileIfNotFound '/etc/ssh/sshd_config' "$(stringToSearchPattern "${config}")" "${config}" 'true' 'false' 'true'
        grep -F "${config}" '/etc/ssh/sshd_config' | grep -v '^\s*#'
    done

    # Restart Service

    restartService 'sshd'

    # Verification

    if [[ "$(isPortOpen '22')" = 'false' ]]
    then
        fatal '\nFATAL : ssh service start failed'
    fi

    umask '0077'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING SSH'

    installDependencies
    install
    installCleanUp
}

main "${@}"