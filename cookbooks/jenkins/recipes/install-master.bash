#!/bin/bash -e

function installDependencies()
{
    if [[ ! -f "${jenkinsTomcatInstallFolder}/bin/catalina.sh" ]]
    then
        "${appPath}/../../tomcat/recipes/install.bash"
    fi
}

function install()
{
    # Set Install Folder Path

    local jenkinsDefaultInstallFolder="$(getUserHomeFolder "${jenkinsUserName}")/.jenkins"

    if [[ "$(isEmptyString "${jenkinsInstallFolder}")" = 'true' ]]
    then
        jenkinsInstallFolder="${jenkinsDefaultInstallFolder}"
    fi

    # Clean Up

    local appName="$(getFileName "${jenkinsDownloadURL}")"

    rm -f -r "${jenkinsDefaultInstallFolder}" \
             "${jenkinsInstallFolder}" \
             "${jenkinsTomcatInstallFolder}/webapps/${appName}.war" \
             "${jenkinsTomcatInstallFolder}/webapps/${appName}"

    # Create Non-Default Jenkins Home

    if [[ "${jenkinsInstallFolder}" != "${jenkinsDefaultInstallFolder}" ]]
    then
        initializeFolder "${jenkinsInstallFolder}"
        ln -s "${jenkinsInstallFolder}" "${jenkinsDefaultInstallFolder}"
        chown -R "${jenkinsUserName}:${jenkinsGroupName}" "${jenkinsDefaultInstallFolder}" "${jenkinsInstallFolder}"
    fi

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${jenkinsInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/jenkins.sh.profile" '/etc/profile.d/jenkins.sh' "${profileConfigData[@]}"

    # Install

    checkExistFolder "${jenkinsTomcatInstallFolder}/webapps"

    local temporaryFile="$(getTemporaryFile)"

    checkExistURL "${jenkinsDownloadURL}"
    debug "\nDownloading '${jenkinsDownloadURL}' to '${temporaryFile}'"
    curl -L "${jenkinsDownloadURL}" -o "${temporaryFile}"
    chown "${jenkinsUserName}:${jenkinsGroupName}" "${temporaryFile}"
    mv "${temporaryFile}" "${jenkinsTomcatInstallFolder}/webapps/${appName}.war"
    sleep 75

    # Display Version

    local jenkinsCLIPath="${jenkinsTomcatInstallFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar"

    checkExistFile "${jenkinsCLIPath}"
    info "\nVersion: $('java' -jar "${jenkinsCLIPath}" \
                              -s "http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}" \
                              version)"

    # Refresh Update Center

    checkTrueFalseString "${jenkinsUpdateAllPlugins}"

    "${appPath}/refresh-master-update-center.bash"

    # Install Plugins

    if [[ ${#jenkinsInstallPlugins[@]} -gt 0 ]]
    then
        "${appPath}/install-master-plugins.bash" "${jenkinsInstallPlugins[@]}"
    fi

    # Update Plugins

    if [[ "${jenkinsUpdateAllPlugins}" = 'true' ]]
    then
        "${appPath}/update-master-plugins.bash"
    fi

    # Safe-Restart Master

    if [[ ${#jenkinsInstallPlugins[@]} -gt 0 || "${jenkinsUpdateAllPlugins}" = 'true' ]]
    then
        "${appPath}/safe-restart-master.bash"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/master.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MASTER JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"