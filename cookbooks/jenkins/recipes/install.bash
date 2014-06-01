#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${tomcatFolder}/webapps/tomcat" "${tomcatFolder}/webapps/tomcat.war"

    # Install

    curl -L "${downloadURL}" -o "${tomcatFolder}/webapps/tomcat.war"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING JENKINS'

    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"
