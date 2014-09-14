#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../attributes/master.bash"
    source "${appPath}/../../../../cookbooks/jenkins/attributes/master.bash"
    source "${appPath}/../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../cookbooks/nginx/attributes/default.bash"
    source "${appPath}/../../../../lib/util.bash"
    source "${appPath}/../lib/util.bash"

    extendOPTPartition "${ccmuiJenkinsDisk}" "${ccmuiJenkinsMountOn}" "${mounthdPartitionNumber}"

    "${appPath}/../../../essential.bash"
    "${appPath}/../../../../cookbooks/maven/recipes/install.bash"
    "${appPath}/../../../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../../../cookbooks/jenkins/recipes/install-master.bash" 'false'
    "${appPath}/../../../../cookbooks/jenkins/recipes/install-master-plugins.bash" 'false' 'true' "${ccmuiJenkinsInstallPlugins[@]}"
    "${appPath}/../../../../cookbooks/ps1/recipes/install.bash" "${jenkinsUserName}"

    # Config SSH and GIT

    cleanUp

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "${jenkinsUserName}" "${jenkinsGroupName}" "$(cat "${appPath}/../files/default/known_hosts")"

    configUserGIT "${jenkinsUserName}" "${ccmuiJenkinsGITUserName}" "${ccmuiJenkinsGITUserEmail}"
    generateUserSSHKey "${jenkinsUserName}"

    # Config Nginx

    "${appPath}/../../../../cookbooks/nginx/recipes/install.bash"

    header 'CONFIGURING NGINX PROXY'

    local jenkinsAppName="$(getFileName "${jenkinsDownloadURL}")"
    local nginxConfigData=(
        '__NGINX_PORT__' "${nginxPort}"
        '__JENKINS_TOMCAT_HTTP_PORT__' "${jenkinsTomcatHTTPPort}"
        '__JENKINS_APP_NAME__' "${jenkinsAppName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/nginx.conf.conf" "${nginxInstallFolder}/conf/nginx.conf" "${nginxConfigData[@]}"

    stop "${nginxServiceName}"
    start "${nginxServiceName}"

    # Display Notice

    displayNotice "${jenkinsUserName}"
}

main "${@}"