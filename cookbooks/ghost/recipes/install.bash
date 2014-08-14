#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'node')" = 'false' || "$(existCommand 'npm')" = 'false' || ! -d "${nodejsInstallFolder}" ]]
    then
        "${appPath}/../../node-js/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    rm -rf "${ghostInstallFolder}"
    mkdir -p "${ghostInstallFolder}"

    # Install

    local currentPath="$(pwd)"

    unzipRemoteFile "${ghostDownloadURL}" "${ghostInstallFolder}"
    cd "${ghostInstallFolder}"
    npm install "--${ghostEnvironment}" --silent
    cd "${currentPath}"

    # Config Server

    local serverConfigData=(
        '__PRODUCTION_URL__' "${ghostProductionURL}"
        '__PRODUCTION_HOST__' "${ghostProductionHost}"
        '__PRODUCTION_PORT__' "${ghostProductionPort}"

        '__DEVELOPMENT_URL__' "${ghostDevelopmentURL}"
        '__DEVELOPMENT_HOST__' "${ghostDevelopmentHost}"
        '__DEVELOPMENT_PORT__' "${ghostDevelopmentPort}"

        '__TESTING_URL__' "${ghostTestingURL}"
        '__TESTING_HOST__' "${ghostTestingHost}"
        '__TESTING_PORT__' "${ghostTestingPort}"
    )

    createFileFromTemplate "${appPath}/../templates/default/config.js.conf" "${ghostInstallFolder}/config.js" "${serverConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__ENVIRONMENT__' "${ghostEnvironment}"
        '__INSTALL_FOLDER__' "${ghostInstallFolder}"

        '__UID__' "${ghostUID}"
        '__GID__' "${ghostGID}"
    )

    createFileFromTemplate "${appPath}/../templates/default/ghost.conf.upstart" "/etc/init/${ghostServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addSystemUser "${ghostUID}" "${ghostGID}"
    chown -R "${ghostUID}":"${ghostGID}" "${ghostInstallFolder}"
    start "${ghostServiceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1
    source "${appPath}/../../node-js/attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GHOST'

    if [[ "${ghostEnvironment}" = 'production' ]]
    then
        checkRequirePort "${ghostProductionPort}"
    elif [[ "${ghostEnvironment}" = 'development' ]]
    then
        checkRequirePort "${ghostDevelopmentPort}"
    fi

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"