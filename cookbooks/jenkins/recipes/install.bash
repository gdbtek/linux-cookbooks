#!/bin/bash

function install()
{
    local appName="$(getFileName "${downloadURL}")"

    # Clean Up

    rm -rf "${tomcatFolder}/webapps/${appName}" "${tomcatFolder}/webapps/${appName}.war"

    # Install

    curl -L "${downloadURL}" -o "${tomcatFolder}/webapps/${appName}.war"
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
