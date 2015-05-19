#!/bin/bash -e

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

    local -r currentPath="$(pwd)"

    cd "${unzipFolder}"
    find '.' -maxdepth 1 -not -name '.' -exec mv '{}' "${EC2_API_TOOLS_INSTALL_FOLDER}" \;
    cd "${currentPath}"
    rm -f -r "${unzipFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${EC2_API_TOOLS_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/default/ec2-api-tools.sh.profile" '/etc/profile.d/ec2-api-tools.sh' "${profileConfigData[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING EC2-API-TOOLS'

    install
    installCleanUp
}

main "${@}"