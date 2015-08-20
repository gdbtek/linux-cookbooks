#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${JQ_INSTALL_FOLDER}"
    mkdir -p "${JQ_INSTALL_FOLDER}/bin"

    # Install

    downloadFile "${JQ_DOWNLOAD_URL}" "${JQ_INSTALL_FOLDER}/jq" 'true'
    chown -R "$(whoami):$(whoami)" "${JQ_INSTALL_FOLDER}"
    chmod 755 "${JQ_INSTALL_FOLDER}/jq"
    symlinkLocalBin "${JQ_INSTALL_FOLDER}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${JQ_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/default/jq.sh.profile" '/etc/profile.d/jq.sh' "${profileConfigData[@]}"

    # Display Version

    info "$("${JQ_INSTALL_FOLDER}/jq" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING JQ'

    install
    installCleanUp
}

main "${@}"