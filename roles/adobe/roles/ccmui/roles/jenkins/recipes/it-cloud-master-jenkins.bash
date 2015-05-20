#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../cookbooks/jenkins/attributes/master.bash"
    source "${appPath}/../../../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../../../cookbooks/nginx/attributes/default.bash"
    source "${appPath}/../../../../../../../libraries/util.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../attributes/master.bash"

    # Extend HD

    extendOPTPartition "${ccmuiJenkinsDisk:?}" "${ccmuiJenkinsMountOn:?}" "${MOUNT_HD_PARTITION_NUMBER}"

    # Install Apps

    local -r hostName='jenkins.ccmui.adobe.com'

    "${appPath}/../../../../../../essential.bash" "${hostName}"
    "${appPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${ccmuiJenkinsNodeJSVersion:?}" "${ccmuiJenkinsNodeJSInstallFolder:?}"
    "${appPath}/../../../../../../../cookbooks/jenkins/recipes/install-master.bash"
    "${appPath}/../../../../../../../cookbooks/jenkins/recipes/install-master-plugins.bash" "${ccmuiJenkinsInstallPlugins[@]}"
    "${appPath}/../../../../../../../cookbooks/jenkins/recipes/safe-restart-master.bash"
    "${appPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami)"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}" "$(cat "${appPath}/../files/default/known_hosts")"

    configUserGIT "${JENKINS_USER_NAME}" "${ccmuiJenkinsGITUserName:?}" "${ccmuiJenkinsGITUserEmail:?}"
    generateUserSSHKey "${JENKINS_USER_NAME}"

    # Config Nginx

    "${appPath}/../../../../../../../cookbooks/nginx/recipes/install.bash"

    header 'CONFIGURING NGINX PROXY'

    local -r nginxConfigData=(
        '__NGINX_PORT__' "${NGINX_PORT}"
        '__JENKINS_TOMCAT_HTTP_PORT__' "${JENKINS_TOMCAT_HTTP_PORT}"
    )

    createFileFromTemplate "${appPath}/../templates/default/nginx.conf.conf" "${NGINX_INSTALL_FOLDER}/conf/nginx.conf" "${nginxConfigData[@]}"

    stop "${NGINX_SERVICE_NAME}"
    start "${NGINX_SERVICE_NAME}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "${JENKINS_USER_NAME}"
}

main "${@}"