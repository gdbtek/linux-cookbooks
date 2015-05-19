#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../cookbooks/jenkins/attributes/slave.bash"
    source "${appPath}/../../../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../../../libraries/util.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../attributes/slave.bash"

    # Extend HD

    extendOPTPartition "${ccmuiJenkinsDisk:?}" "${ccmuiJenkinsMountOn:?}" "${MOUNT_HD_PARTITION_NUMBER:?}"

    # Install Apps

    local -r hostName='jenkins-slave-XXX.ccmui.adobe.com'

    "${appPath}/../../../../../../essential.bash" "${hostName}"
    "${appPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${ccmuiJenkinsNodeJSVersion:?}" "${ccmuiJenkinsNodeJSInstallFolder:?}"
    "${appPath}/../../../../../../../cookbooks/jenkins/recipes/install-slave.bash"
    "${appPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami)"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}" "$(cat "${appPath}/../files/default/known_hosts")"

    configUserGIT "${JENKINS_USER_NAME}" "${ccmuiJenkinsGITUserName:?}" "${ccmuiJenkinsGITUserEmail:?}"
    generateUserSSHKey "${JENKINS_USER_NAME}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "${JENKINS_USER_NAME}"
}

main "${@}"