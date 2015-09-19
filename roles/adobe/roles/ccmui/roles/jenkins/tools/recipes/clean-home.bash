#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../../cookbooks/tomcat/attributes/default.bash"

    # Master and Slaves

    local -r deleteCacheCommand="sudo rm -f -r \
        ~root/.cache \
        ~root/.jenkins \
        ~root/.m2 \
        ~root/.node-gyp \
        ~root/.npm \
        ~root/.oracle_jre_usage \
        ~root/.packer.d \
        ~root/.qws \
        ~root/tmp \
        ~${TOMCAT_USER_NAME}/.cache \
        ~${TOMCAT_USER_NAME}/.m2 \
        ~${TOMCAT_USER_NAME}/.node-gyp \
        ~${TOMCAT_USER_NAME}/.npm \
        ~${TOMCAT_USER_NAME}/.oracle_jre_usage \
        ~${TOMCAT_USER_NAME}/.packer.d \
        ~${TOMCAT_USER_NAME}/.qws \
        ~${TOMCAT_USER_NAME}/tmp \
    "

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${deleteCacheCommand}" \
        --machine-type 'masters-slaves'
}

main "${@}"