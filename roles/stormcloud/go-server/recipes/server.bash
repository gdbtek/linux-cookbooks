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
    # Clean Up

    rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/* "${stormcloudNPMCacheFolder}"
    mkdir -p "${stormcloudNPMCacheFolder}"
    chown www-data:root "${stormcloudNPMCacheFolder}"

    # Default

    local defaultConfigData=(
        '__GO_SERVER_HOST__' "${stormcloudGoServerHost}"
        '__SSL_CRT_FILE__' "${stormcloudSSLCRTFile}"
        '__SSL_RSA_KEY_FILE__' "${stormcloudSSLRSAKeyFile}"
    )

    createFileFromTemplate "${appPath}/../files/nginx/default" '/etc/nginx/sites-enabled/default' "${defaultConfigData[@]}"

    # NPM

    local npmConfigData=(
        '__NPM_CACHE_FOLDER__' "${stormcloudNPMCacheFolder}"
        '__NPM_SERVER_HOST__' "${stormcloudNPMServerHost}"
    )

    createFileFromTemplate "${appPath}/../files/nginx/npm" '/etc/nginx/sites-enabled/npm' "${npmConfigData[@]}"

    # Start

    service nginx stop
    service nginx start
}

function configGoServer()
{
    local oldCruiseConfigXMLFile="${appPath}/../files/cruise-config.xml"
    local currentCruiseConfigXMLFile='/opt/go-server/server/config/cruise-config.xml'
    local currentServerID="$(xmlstarlet select -t -v "/cruise/server/@serverId" "${currentCruiseConfigXMLFile}")"

    if [[ "$(isEmptyString "${currentServerID}")" = 'true' ]]
    then
        fatal "\nFATAL: select 'serverId' attribute not found in '${currentCruiseConfigXMLFile}'"
    fi

    local newCruiseConfigXMLFileContent="$(xmlstarlet edit --update "/cruise/server/@serverId" --value "${currentServerID}" "${oldCruiseConfigXMLFile}")"

    if [[ "$(cat "${oldCruiseConfigXMLFile}")" = "${newCruiseConfigXMLFileContent}" ]]
    then
        fatal "\nFATAL: update 'serverId' attribute not found in '${oldCruiseConfigXMLFile}'"
    fi

    echo "${newCruiseConfigXMLFileContent}" > "${currentCruiseConfigXMLFile}"
}

function displayServerNotice()
{
    header 'NOTICES'

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
    sleep 15
    configServer
    "${appPath}/../../../../cookbooks/ps1/recipes/install.bash" 'go' 'ubuntu' || exit 1

    displayOpenPorts
    displayServerNotice
}

main "${@}"