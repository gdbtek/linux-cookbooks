#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${EC2_API_TOOLS_JDK_INSTALL_FOLDER}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${EC2_API_TOOLS_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${EC2_API_TOOLS_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${EC2_API_TOOLS_DOWNLOAD_URL}" "${EC2_API_TOOLS_INSTALL_FOLDER}"

    local -r unzipFolder="$(find "${EC2_API_TOOLS_INSTALL_FOLDER}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(wc -l <<< "${unzipFolder}")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    moveFolderContent "${unzipFolder}" "${EC2_API_TOOLS_INSTALL_FOLDER}"
    rm -f -r "${unzipFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${EC2_API_TOOLS_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/ec2-api-tools.sh.profile" '/etc/profile.d/ec2-api-tools.sh' "${profileConfigData[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING EC2-API-TOOLS'

    installDependencies
    install
    installCleanUp
}

main "${@}"