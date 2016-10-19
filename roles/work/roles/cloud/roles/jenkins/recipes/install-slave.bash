#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../cookbooks/jenkins/attributes/slave.bash"
    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/slave.bash"

    # Clean Up

    remountTMP
    resetLogs

    # Install Apps

    local -r hostName='jenkins-slave'

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        apt-get update -m
    fi

    "${appFolderPath}/../../../../../../essential.bash" "${hostName}" "centos, $(whoami), root, ubuntu"
    "${appFolderPath}/../../../../../../../cookbooks/ant/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/data-dog/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CLOUD_JENKINS_NODE_JS_VERSION}" "${CLOUD_JENKINS_NODE_JS_INSTALL_FOLDER}"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/install-slave.bash"
    "${appFolderPath}/../../../../../../../cookbooks/packer/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami)"
    "${appFolderPath}/../../../../../../../cookbooks/secret-server-console/recipes/install.bash"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appFolderPath}/../../../../../files/authorized_keys")"
    addUserSSHKnownHost "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}" "$(cat "${appFolderPath}/../../../../../files/known_hosts")"

    configUserGIT "${JENKINS_USER_NAME}" "${CLOUD_JENKINS_GIT_USER_NAME}" "${CLOUD_JENKINS_GIT_USER_EMAIL}"
    generateUserSSHKey "${JENKINS_USER_NAME}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "${JENKINS_USER_NAME}"
}

main "${@}"