#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../../cookbooks/jenkins/attributes/slave.bash"
    source "${appPath}/../../../../../../../../cookbooks/tomcat/attributes/default.bash"

    # Master and Slaves

    local -r deleteCacheCommand="sudo rm -f -r \
        /tmp/* \
        /var/tmp/* \
        ~root/.cache \
        ~root/.node-gyp \
        ~root/.npm \
        ~root/.qws \
        ~root/tmp \
        ~${TOMCAT_USER_NAME}/.cache \
        ~${TOMCAT_USER_NAME}/.node-gyp \
        ~${TOMCAT_USER_NAME}/.npm \
        ~${TOMCAT_USER_NAME}/.qws \
        ~${TOMCAT_USER_NAME}/tmp \
    "

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${deleteCacheCommand}" \
        --machine-type 'masters-slaves'

    # Slaves

    local -r deleteNodeModulesCommand="find ${JENKINS_WORKSPACE_FOLDER}/workspace -maxdepth 5 -type d -name 'node_modules' -exec rm -f -r {} \;"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${deleteNodeModulesCommand}" \
        --machine-type 'slaves'
}

main "${@}"