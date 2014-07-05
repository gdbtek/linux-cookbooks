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
    mkdir -p "$(dirname "${stormcloudSSLCRTFile}")" "$(dirname "${stormcloudSSLRSAKeyFile}")"

    cp -f "${appPath}/../files/ssl/ssl.crt" "${stormcloudSSLCRTFile}"
    cp -f "${appPath}/../files/ssl/ssl-rsa.key" "${stormcloudSSLRSAKeyFile}"
}

function configNginx()
{
    rm -f '/etc/nginx/sites-enabled/default'

    # Main

    local mainConfigData=(
        '__GO_SERVER_HOST__' "${stormcloudGoServerHost}"
        '__SSL_CRT_FILE__' "${stormcloudSSLCRTFile}"
        '__SSL_RSA_KEY_FILE__' "${stormcloudSSLRSAKeyFile}"
    )

    createFileFromTemplate "${appPath}/../files/nginx/main" '/etc/nginx/sites-available' "${mainConfigData[@]}"

    if [[ ! -f '/etc/nginx/sites-enabled/main' ]]
    then
        ln -s '/etc/nginx/sites-available/main' '/etc/nginx/sites-enabled/main'
    fi

    # Proxy

    local npmConfigData=(
        '__NPM_SERVER_HOST__' "${stormcloudNPMServerHost}"
    )

    createFileFromTemplate "${appPath}/../files/nginx/npm" '/etc/nginx/sites-available' "${npmConfigData[@]}"

    if [[ ! -f '/etc/nginx/sites-enabled/npm' ]]
    then
        ln -s '/etc/nginx/sites-available/npm' '/etc/nginx/sites-enabled/npm'
    fi

    # Start

    service nginx stop
    service nginx start
}

function configGoServer()
{
    echo
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
    configGoServer
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