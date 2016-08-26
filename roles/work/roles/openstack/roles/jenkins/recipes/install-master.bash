#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../cookbooks/jenkins/attributes/master.bash"
    source "${appFolderPath}/../../../../../../../cookbooks/nginx/attributes/default.bash"
    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/master.bash"

    # Clean Up

    resetLogs

    # Install Apps

    local -r hostName='jenkins-master'

    "${appFolderPath}/../../../../../../essential.bash" "${hostName}"
    "${appFolderPath}/../../../../../../../cookbooks/ant/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${OPENSTACK_JENKINS_NODE_JS_VERSION}" "${OPENSTACK_JENKINS_NODE_JS_INSTALL_FOLDER}"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/install-master.bash"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/install-master-plugins.bash" "${OPENSTACK_JENKINS_INSTALL_PLUGINS[@]}"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/safe-restart-master.bash"
    "${appFolderPath}/../../../../../../../cookbooks/packer/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami)"
    "${appFolderPath}/../../../../../../../cookbooks/secret-server-console/recipes/install.bash"

    # Config SSH and GIT

    addUserSSHKnownHost "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}" "$(cat "${appFolderPath}/../files/known_hosts")"

    configUserGIT "${JENKINS_USER_NAME}" "${OPENSTACK_JENKINS_GIT_USER_NAME}" "${OPENSTACK_JENKINS_GIT_USER_EMAIL}"
    generateUserSSHKey "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}"

    # Config Nginx

    "${appFolderPath}/../../../../../../../cookbooks/nginx/recipes/install-from-source.bash"

    header 'CONFIGURING NGINX PROXY'

    local -r nginxConfigData=(
        '__NGINX_PORT__' "${NGINX_PORT}"
        '__JENKINS_TOMCAT_HTTP_PORT__' "${JENKINS_TOMCAT_HTTP_PORT}"
    )

    createFileFromTemplate "${appFolderPath}/../templates/nginx.conf.conf" "${NGINX_INSTALL_FOLDER}/conf/nginx.conf" "${nginxConfigData[@]}"

    stop "${NGINX_SERVICE_NAME}"
    start "${NGINX_SERVICE_NAME}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "${JENKINS_USER_NAME}"
}

main "${@}"