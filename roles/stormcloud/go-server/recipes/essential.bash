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
    cp "${appPath}/../files/initctl" '/usr/local/bin'
    chmod 755 '/usr/local/bin/initctl'

    appendToFileIfNotFound '/etc/sudoers' "^\s*go\s+ALL=\(ALL\)\s+NOPASSWD:ALL\s*$" "\ngo ALL=\(ALL\) NOPASSWD:ALL" 'true' 'true'
}

function configKnownHosts()
{
    cp "${appPath}/../files/known_hosts" ~go/.ssh
    chmod 600 ~go/.ssh/known_hosts
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
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    "${appPath}/../../../../cookbooks/apt-source/recipes/install.bash" || exit 1
    "${appPath}/../../../../cookbooks/mount-hd/recipes/install.bash" '/dev/sdb' '/opt/go-server' || exit 1

    "${appPath}/../../../essential.bash" || exit 1

    "${appPath}/../../../../cookbooks/aws-cli/recipes/install.bash" || exit 1
    "${appPath}/../../../../cookbooks/jdk/recipes/install.bash" || exit 1
    "${appPath}/../../../../cookbooks/node-js/recipes/install.bash" || exit 1

    installPackages

    configGit
    configInitDaemonControlTool
    configKnownHosts
    configAuthorizedKeys
    configNPM
}

main "${@}"