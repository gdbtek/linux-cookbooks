#!/bin/bash

function configRootAuthorizedKeys()
{
    mkdir -p ~root/.ssh &&
    chmod 700 ~root/.ssh &&
    cp "${appPath}/../files/ssh/authorized_keys" ~root/.ssh &&
    chmod 600 ~root/.ssh/authorized_keys
}

function configInitDaemonControlTool()
{
    if [[ "$(getMachineRelease)" = '13.10' ]]
    then
        cp "${appPath}/../files/initctl" '/usr/local/bin' &&
        chmod 755 '/usr/local/bin/initctl'

        appendToFileIfNotFound '/etc/sudoers' "^\s*go\s+ALL=\(ALL\)\s+NOPASSWD:ALL\s*$" 'go ALL=(ALL) NOPASSWD:ALL' 'true' 'false'
    fi
}

function configGoAWS()
{
    mkdir -p ~go/.aws &&
    chmod 700 ~go/.aws &&
    touch ~go/.aws/config.json &&
    chmod 600 ~go/.aws/config.json &&
    chown -R go:go ~go/.aws
}

function configGoGit()
{
    su - go -c "git config --global user.name "${stormcloudGitUserName}""
    su - go -c "git config --global user.email "${stormcloudGitUserEmail}""
    su - go -c 'git config --global push.default simple'
}

function configGoHomeDirectory()
{
    if [[ ! -d '/var/go' ]]
    then
        ln -s '/home/go' '/var/go'
    fi
}

function configGoKnownHosts()
{
    mkdir -p ~go/.ssh &&
    chmod 700 ~go/.ssh &&
    cp "${appPath}/../files/ssh/known_hosts" ~go/.ssh &&
    chmod 600 ~go/.ssh/known_hosts &&
    chown -R go:go ~go/.ssh
}

function configGoNPM()
{
    local npmConfigData=('__NPM_SERVER_HOST__' "${stormcloudNPMServerHost}")

    createFileFromTemplate "${appPath}/../files/.npmrc" ~go/.npmrc "${npmConfigData[@]}"
    chmod 600 ~go/.npmrc &&
    chown go:go ~go/.npmrc
}

function configGoSSHKey()
{
    rm -f ~go/.ssh/id_rsa*

    expect << DONE
        spawn su - go -c 'ssh-keygen'
        expect "Enter file in which to save the key (*): "
        send -- "\r"
        expect "Enter passphrase (empty for no passphrase): "
        send -- "\r"
        expect "Enter same passphrase again: "
        send -- "\r"
        expect eof
DONE

    chmod 600 ~go/.ssh/id_rsa*
}

function displayNotice()
{
    header 'NOTICES'

    info "-> Next is to copy this RSA to your git account:"
    cat ~go/.ssh/id_rsa.pub

    info "\n-> Nex is to update ~go/.aws/config.json"
}

function configAgent()
{
    header 'CONFIGURING AGENT'

    installAptGetPackages "${stormcloudAgentPackages[@]}"

    configRootAuthorizedKeys
    configInitDaemonControlTool

    configGoAWS
    configGoGit
    configGoHomeDirectory
    configGoKnownHosts
    configGoNPM
    configGoSSHKey
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    "${appPath}/essential.bash" || exit 1
    "${appPath}/../../../../cookbooks/go-server/recipes/install-agent.bash" "${stormcloudGoServerHost}" || exit 1
    configAgent
    "${appPath}/../../../../cookbooks/ps1/recipes/install.bash" 'go' 'ubuntu' || exit 1
    displayNotice
}

main "${@}"