#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../../cookbooks/tomcat/attributes/default.bash"

    local -r command="sudo rm -f -r \
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
        --attribute-file "${appPath}/../attributes/jenkins.bash" \
        --command "${command}" \
        --machine-type 'master-slave'
}

main "${@}"