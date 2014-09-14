#!/bin/bash -e

function install()
{
    local refreshUpdateCenter="${1}"
    local safeRestart="${2}"
    local pluginList="${@:3}"

    checkTrueFalseString "${refreshUpdateCenter}"
    checkTrueFalseString "${safeRestart}"

    if [[ "$(isEmptyString "${pluginList}")" = 'false' ]]
    then
        local appName="$(getFileName "${jenkinsDownloadURL}")"
        local jenkinsCLIPath="${jenkinsTomcatInstallFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
        local jenkinsAppURL="http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}"

        checkNonEmptyString "${appName}"
        checkExistFile "${jenkinsCLIPath}"
        checkExistURL "${jenkinsAppURL}"

        if [[ "${refreshUpdateCenter}" = 'true' ]]
        then
            "${appPath}/refresh-master-update-center.bash"
            echo
        fi

        java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" install-plugin ${pluginList}

        if [[ "${safeRestart}" = 'true' ]]
        then
            if [[ "${refreshUpdateCenter}" = 'true' ]]
            then
                sleep 5
            fi

            "${appPath}/safe-restart-master.bash"
        fi
    else
        info "No installs/updates available"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/master.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MASTER PLUGINS JENKINS'

    install "${@}"
    installCleanUp
}

main "${@}"