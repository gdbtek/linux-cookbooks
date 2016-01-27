#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../cookbooks/jenkins/attributes/master.bash"
    source "${appFolderPath}/../../../../../../../cookbooks/nginx/attributes/default.bash"
    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/amazon-master.bash"

    # Clean Up

    resetLogs

    # Extend HD

    "${appFolderPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_JENKINS_DISK}" "${CCMUI_JENKINS_MOUNT_ON}"

    # Install Apps

    local -r hostName='jenkins-pub.ccmui.adobe.com'

    "${appFolderPath}/../../../../../../essential.bash" "${hostName}"
    "${appFolderPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CCMUI_JENKINS_NODE_JS_VERSION}" "${CCMUI_JENKINS_NODE_JS_INSTALL_FOLDER}"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/install-master.bash"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/install-master-plugins.bash" "${CCMUI_JENKINS_INSTALL_PLUGINS[@]}"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/safe-restart-master.bash"
    "${appFolderPath}/../../../../../../../cookbooks/packer/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami), ubuntu"

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
}

main "${@}"