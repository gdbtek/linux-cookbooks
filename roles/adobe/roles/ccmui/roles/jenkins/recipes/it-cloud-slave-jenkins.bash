#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../cookbooks/jenkins/attributes/slave.bash"
    source "${appPath}/../../../../../../../libraries/util.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../attributes/it-cloud-slave.bash"

    # Clean Up

    resetLogs

    # Extend HD

    "${appPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_JENKINS_DISK}" "${CCMUI_JENKINS_MOUNT_ON}"

    # Install Apps

    local -r hostName='jenkins-slave-XXX.ccmui.adobe.com'

    "${appPath}/../../../../../../essential.bash" "${hostName}"
    "${appPath}/../../../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CCMUI_JENKINS_NODE_JS_VERSION}" "${CCMUI_JENKINS_NODE_JS_INSTALL_FOLDER}"
    "${appPath}/../../../../../../../cookbooks/jenkins/recipes/install-slave.bash"
    "${appPath}/../../../../../../../cookbooks/packer/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami)"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/authorized_keys")"
    addUserSSHKnownHost "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}" "$(cat "${appPath}/../files/known_hosts")"

    configUserGIT "${JENKINS_USER_NAME}" "${CCMUI_JENKINS_GIT_USER_NAME}" "${CCMUI_JENKINS_GIT_USER_EMAIL}"
    generateUserSSHKey "${JENKINS_USER_NAME}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "${JENKINS_USER_NAME}"
}

main "${@}"