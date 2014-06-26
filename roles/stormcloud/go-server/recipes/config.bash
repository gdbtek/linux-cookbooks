#!/bin/bash

function installPackages()
{
    local package=''

    for package in ${stormcloudPackages[@]}
    do
        installAptGetPackage "${package}"
    done
}

function configGit()
{
    sudo -u go bash -c "git config --global user.name "${stormcloudGitUserName}""
    sudo -u go bash -c "git config --global user.email "${stormcloudGitUserEmail}""
    sudo -u go bash -c 'git config --global push.default simple'
}

function configInitDaemonControlTool()
{
    if [[ "$(getMachineRelease)" = '13.10' ]]
    then
        cp "${appPath}/../files/initctl" '/usr/local/bin'
        chmod 755 '/usr/local/bin/initctl'

        appendToFileIfNotFound '/etc/sudoers' "^\s*go\s+ALL=\(ALL\)\s+NOPASSWD:ALL\s*$" 'go ALL=(ALL) NOPASSWD:ALL' 'true' 'false'
    fi
}

function configKnownHosts()
{
    mkdir -p ~go/.ssh
    cp "${appPath}/../files/known_hosts" ~go/.ssh
    chmod 600 ~go/.ssh/known_hosts
    chown -R go:go ~go/.ssh
}

function configAuthorizedKeys()
{
    cp "${appPath}/../files/authorized_keys" ~root/.ssh
    chmod 600 ~root/.ssh/authorized_keys
}

function configNPM()
{
    cp "${appPath}/../files/.npmrc" ~go
    chmod 600 ~go/.npmrc
    chown go:go ~go/.npmrc
}

function configGoHomeDirectory()
{
    ln -s '/home/go' '/var/go'
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    installPackages

    # configGit
    configInitDaemonControlTool
    configKnownHosts
    configAuthorizedKeys
    configNPM
    configGoHomeDirectory
}

main "${@}"