#!/bin/bash

function installDependencies()
{
    if [[ "$(isEmptyString "${jenkinsTomcatFolder}")" = 'true' ]]
    then
        jenkinsTomcatFolder="${tomcatInstallFolder}"
    fi

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

    if [[ "$(isEmptyString "${jenkinsUID}")" = 'true' ]]
    then
        local jenkinsUID="${tomcatUID}"
    fi

    if [[ "$(isEmptyString "${jenkinsGID}")" = 'true' ]]
    then
        local jenkinsGID="${tomcatUID}"
    fi

    chown -R "${jenkinsUID}":"${jenkinsGID}" "${jenkinsTomcatFolder}/webapps/${appName}.war"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1
    source "${appPath}/../../tomcat/attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING JENKINS'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"