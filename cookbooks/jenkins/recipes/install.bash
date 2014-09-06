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

    rm -f -r "${jenkinsTomcatFolder}/webapps/${appName}" "${jenkinsTomcatFolder}/webapps/${appName}.war"

    # Install

    if [[ ! -d "${jenkinsTomcatFolder}/webapps" ]]
    then
        fatal "\nFATAL : folder '${jenkinsTomcatFolder}/webapps' not found!"
    fi

    local temporaryFile="$(getTemporaryFile)"

    checkExistURL "${jenkinsDownloadURL}"
    debug "\nDownloading '${jenkinsDownloadURL}' to '${temporaryFile}'"
    curl -L "${jenkinsDownloadURL}" -o "${temporaryFile}"
    chown "${jenkinsUserName}:${jenkinsGroupName}" "${temporaryFile}"
    mv "${temporaryFile}" "${jenkinsTomcatFolder}/webapps/${appName}.war"

    # Display Version

    sleep 60
    info "\nVersion: $('java' -jar "${jenkinsTomcatFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar" -s "http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}" version)"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"