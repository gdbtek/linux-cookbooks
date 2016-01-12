#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../cookbooks/nginx/attributes/default.bash"
    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    # Clean Up

    remountTMP
    resetLogs

    # Extend HD

    "${appFolderPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_FEATURE_FLIPPER_DISK}" "${CCMUI_FEATURE_FLIPPER_MOUNT_ON}"

    # Install Apps

    "${appFolderPath}/../../../../../../essential.bash" 'featureflipper.ccmui.adobe.com'
    "${appFolderPath}/../../../../../../../cookbooks/mongodb/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CCMUI_FEATURE_FLIPPER_NODE_JS_VERSION}" "${CCMUI_FEATURE_FLIPPER_NODE_JS_INSTALL_FOLDER}"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appFolderPath}/../files/authorized_keys")"
    addUserSSHKnownHost "$(whoami)" "$(whoami)" "$(cat "${appFolderPath}/../files/known_hosts")"

    configUserGIT "$(whoami)" "${CCMUI_FEATURE_FLIPPER_GIT_USER_NAME}" "${CCMUI_FEATURE_FLIPPER_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Config Nginx

    "${appFolderPath}/../../../../../../../cookbooks/nginx/recipes/install.bash"

    header 'CONFIGURING NGINX PROXY'

    local -r nginxConfigData=(
        '__NGINX_PORT__' "${NGINX_PORT}"
        '__TORNADO_HTTP_PORT__' "${CCMUI_FEATURE_FLIPPER_TORNADO_HTTP_PORT}"
    )

    createFileFromTemplate "${appFolderPath}/../templates/nginx.conf.conf" "${NGINX_INSTALL_FOLDER}/conf/nginx.conf" "${nginxConfigData[@]}"

    stop "${NGINX_SERVICE_NAME}"
    start "${NGINX_SERVICE_NAME}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"