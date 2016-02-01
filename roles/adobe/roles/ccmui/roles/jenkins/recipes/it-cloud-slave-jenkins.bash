#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../cookbooks/jenkins/attributes/slave.bash"
    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/it-cloud-slave.bash"

    # Clean Up

    remountTMP
    resetLogs

    # Extend HD

    "${appFolderPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_JENKINS_DISK}" "${CCMUI_JENKINS_MOUNT_ON}"

    # Install Apps

    local -r hostName='jenkins-slave-XXX.ccmui.adobe.com'

    "${appFolderPath}/../../../../../../essential.bash" "${hostName}"
    "${appFolderPath}/../../../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CCMUI_JENKINS_NODE_JS_VERSION}" "${CCMUI_JENKINS_NODE_JS_INSTALL_FOLDER}"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/install-slave.bash"
    "${appFolderPath}/../../../../../../../cookbooks/packer/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami)"
    "${appFolderPath}/../../../../../../../cookbooks/secret-server-console/recipes/install.bash"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appFolderPath}/../files/authorized_keys")"
    addUserSSHKnownHost "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}" "$(cat "${appFolderPath}/../files/known_hosts")"

    configUserGIT "${JENKINS_USER_NAME}" "${CCMUI_JENKINS_GIT_USER_NAME}" "${CCMUI_JENKINS_GIT_USER_EMAIL}"
    generateUserSSHKey "${JENKINS_USER_NAME}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "${JENKINS_USER_NAME}"
}

main "${@}"