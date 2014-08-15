#!/bin/bash -e

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

    rm --force --recursive "${jenkinsTomcatFolder}/webapps/${appName}" "${jenkinsTomcatFolder}/webapps/${appName}.war"

    # Install

    curl --location "${jenkinsDownloadURL}" --output "${jenkinsTomcatFolder}/webapps/${appName}.war"
    chown --recursive "${jenkinsUID}":"${jenkinsGID}" "${jenkinsTomcatFolder}/webapps/${appName}.war"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"