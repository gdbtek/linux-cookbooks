#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../cookbooks/jenkins/attributes/master.bash"
    source "${appFolderPath}/../../../../../../../cookbooks/nginx/attributes/source.bash"
    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/app.bash"
    source "${appFolderPath}/../attributes/master.bash"

    # Clean Up

    addSwapSpace
    remountTMP
    redirectJDKTMPDir
    resetLogs

    # Install Apps

    local -r hostName='jenkins-master'

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        apt-get update -m
    fi

    "${appFolderPath}/../../../../../../essential.bash" "${hostName}" "$(arrayToString "${CLOUD_USERS[@]}")"
    "${appFolderPath}/../../../../../../../cookbooks/akamai-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/ant/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/chef-client/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/docker/recipes/install.bash" || true
    "${appFolderPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CLOUD_JENKINS_NODE_JS_VERSION}" "${CLOUD_JENKINS_NODE_JS_INSTALL_FOLDER_PATH}"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/install-master.bash"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/safe-restart-master.bash"
    "${appFolderPath}/../../../../../../../cookbooks/packer/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/porter/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami)"
    "${appFolderPath}/../../../../../../../cookbooks/secret-server-console/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/terraform/recipes/install.bash"

    # Config SSH and GIT

    configUsersSSH "${CLOUD_USERS[@]}"

    configUserGIT "${JENKINS_USER_NAME}" "${CLOUD_JENKINS_GIT_USER_NAME}" "${CLOUD_JENKINS_GIT_USER_EMAIL}"
    generateUserSSHKey "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}"

    # Config Nginx

    "${appFolderPath}/../../../../../../../cookbooks/nginx/recipes/install-from-source.bash"

    header 'CONFIGURING NGINX PROXY'

    local -r nginxConfigData=(
        '__NGINX_PORT__' "${NGINX_PORT}"
        '__JENKINS_TOMCAT_HTTP_PORT__' "${JENKINS_TOMCAT_HTTP_PORT}"
    )

    createFileFromTemplate "${appFolderPath}/../templates/nginx.conf.conf" "${NGINX_INSTALL_FOLDER_PATH}/conf/nginx.conf" "${nginxConfigData[@]}"

    restartService "${NGINX_SERVICE_NAME}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "${JENKINS_USER_NAME}" 'true'

    # Finish

    postUpMessage
}

main "${@}"