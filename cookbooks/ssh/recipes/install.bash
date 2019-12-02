#!/bin/bash -e

function installDependencies()
{
    installPackages 'openssh-server'
}

function install()
{
    umask '0022'

    local config=''

    for config in "${SSH_CONFIGS[@]}"
    do
        header "ADDING SSH CONFIG '${config}'"

        local searchRegex=''
        searchRegex="(^[[:space:]]*)($(awk '{ print $1 }' <<< "${config}")[[:space:]]+.*$)"

        sed -E "s/${searchRegex}/\1${config}/g" \
            <<< "$(cat '/etc/ssh/sshd_config')" \
        > '/etc/ssh/sshd_config' || true

        appendToFileIfNotFound \
            '/etc/ssh/sshd_config' \
            "$(stringToSearchPattern "${config}")" \
            "${config}" \
            'true' \
            'false' \
            'true'

        grep -F "${config}" '/etc/ssh/sshd_config' | grep -v '^\s*#'
    done

    restartService 'sshd'

    if [[ "$(isPortOpen '22')" = 'false' ]]
    then
        fatal '\nFATAL : ssh service start failed'
    fi

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING SSH'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"