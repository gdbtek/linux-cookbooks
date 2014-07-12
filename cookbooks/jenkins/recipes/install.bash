#!/bin/bash

function installDependencies()
{
    if [[ ! -f "${jenkinsTomcatFolder}/bin/catalina.sh" ]]
    then
        "${appPath}/../../tomcat/recipes/install.bash"
    fi
}

function install()
{
    local appName="$(getFileName "${jenkinsDownloadURL}")"

    # Clean Up

    rm -rf "${jenkinsTomcatFolder}/webapps/${appName}" "${jenkinsTomcatFolder}/webapps/${appName}.war"

    # Install

    curl -L "${jenkinsDownloadURL}" -o "${jenkinsTomcatFolder}/webapps/${appName}.war"
    chown -R "${jenkinsUID}":"${jenkinsGID}" "${jenkinsTomcatFolder}/webapps/${appName}.war"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING JENKINS'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"