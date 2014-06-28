#!/bin/bash

function configRootAuthorizedKeys()
{
    mkdir -p ~root/.ssh &&
    chmod 700 ~root/.ssh &&
    cp "${appPath}/../files/ssh/authorized_keys" ~root/.ssh &&
    chmod 600 ~root/.ssh/authorized_keys
}

function configETCHosts()
{
    appendToFileIfNotFound '/etc/hosts' "^\s*127.0.0.1\s+${stormcloudNPMServerHost}\s*$" "127.0.0.1 ${stormcloudNPMServerHost}" 'true' 'false'
}

function configSSL()
{
    cp -r "${appPath}/../files/ssl" '/opt'
}

function configNginx()
{
    rm -f '/etc/nginx/sites-enabled/default'

    cp -r "${appPath}/../files/nginx/go" '/etc/nginx/sites-available'
    cp -r "${appPath}/../files/nginx/npm-proxy" '/etc/nginx/sites-available'

    ln -s '/etc/nginx/sites-available/go' '/etc/nginx/sites-enabled/go'
    ln -s '/etc/nginx/sites-available/npm-proxy' '/etc/nginx/sites-enabled/npm-proxy'
}

function displayServerNotice()
{
    info "\n-> Next is to update AWS Route 53 of '${stormcloudGoServerHost}' to point to '$(hostname)'"
}

function configServer()
{
    installAptGetPackages "${stormcloudServerPackages[@]}"

    configRootAuthorizedKeys

    configETCHosts
    configSSL
    configNginx
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    "${appPath}/essential.bash" || exit 1
    "${appPath}/../../../../cookbooks/go-server/recipes/install-server.bash" || exit 1
    configServer
    "${appPath}/../../../../cookbooks/ps1/recipes/install.bash" 'go' 'ubuntu' || exit 1
}

main "${@}"