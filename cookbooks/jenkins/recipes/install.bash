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

    local jenkinsDefaultHomeFolder="$(getUserHomeFolder "${jenkinsUserName}")/.jenkins"

    rm -f -r "${jenkinsDefaultHomeFolder}" \
             "${jenkinsTomcatFolder}/webapps/${appName}" \
             "${jenkinsTomcatFolder}/webapps/${appName}.war"

    # Create Jenkins Home

    if [[ "${jenkinsDefaultHomeFolder}" != "${jenkinsHomeFolder}" && "$(isEmptyString "${jenkinsHomeFolder}")" = 'false' ]]
    then
        initializeFolder "${jenkinsHomeFolder}"
        ln -s "${jenkinsHomeFolder}" "${jenkinsDefaultHomeFolder}"
        chown -R "${jenkinsUserName}:${jenkinsGroupName}" "${jenkinsDefaultHomeFolder}"
    fi

    # Install

    checkExistFolder "${jenkinsTomcatFolder}/webapps"

    local temporaryFile="$(getTemporaryFile)"

    checkExistURL "${jenkinsDownloadURL}"
    debug "\nDownloading '${jenkinsDownloadURL}' to '${temporaryFile}'"
    curl -L "${jenkinsDownloadURL}" -o "${temporaryFile}"
    chown "${jenkinsUserName}:${jenkinsGroupName}" "${temporaryFile}"
    mv "${temporaryFile}" "${jenkinsTomcatFolder}/webapps/${appName}.war"
    sleep 60

    # Display Version

    info "\nVersion: $('java' -jar "${jenkinsTomcatFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar" \
                              -s "http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}" \
                              version)"

    # Refresh Update Center

    if [[ "${jenkinsUpdateAllPlugins}" = 'false' && ${#jenkinsInstallPlugins[@]} -lt 1 ]]
    then
        "${appPath}/refresh-update-center.bash"
    fi

    # Update Plugins

    if [[ "${jenkinsUpdateAllPlugins}" = 'true' ]]
    then
        "${appPath}/update-plugins.bash"
    fi

    # Install Plugins

    if [[ ${#jenkinsInstallPlugins[@]} -gt 0 ]]
    then
        "${appPath}/install-plugins.bash" "${jenkinsInstallPlugins[@]}"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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