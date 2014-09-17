#!/bin/bash -e

function install()
{
    # Clean Up

    local appName="$(getFileName "${jenkinsDownloadURL}")"

    rm -f -r "${jenkinsTomcatInstallFolder}/webapps/${appName}.war" \
             "${jenkinsTomcatInstallFolder}/webapps/${appName}"

    # Install

    checkExistFolder "${jenkinsTomcatInstallFolder}/webapps"
    jenkinsMasterDownloadWARApp

    # Display Version

    local jenkinsCLIPath="${jenkinsTomcatInstallFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar"

    checkExistFile "${jenkinsCLIPath}"
    info "\nVersion: $('java' -jar "${jenkinsCLIPath}" \
                              -s "http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}" \
                              version)"

    # Refresh Update Center

    checkTrueFalseString "${jenkinsUpdateAllPlugins}"

    "${appPath}/refresh-master-update-center.bash"

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
    source "${appPath}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'UPGRADING MASTER JENKINS'

    install
    installCleanUp
}

main "${@}"