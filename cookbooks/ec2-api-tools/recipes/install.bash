#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${ec2apitoolsInstallFolder}"

    # Install

    unzipRemoteFile "${ec2apitoolsDownloadURL}" "${ec2apitoolsInstallFolder}"

    local unzipFolder="$(find "${ec2apitoolsInstallFolder}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(wc -l <<< "${unzipFolder}")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    local currentPath="$(pwd)"

    cd "${unzipFolder}"
    find '.' -maxdepth 1 ! -name '.' -exec mv '{}' "${ec2apitoolsInstallFolder}" \;
    cd "${currentPath}"
    rm -f -r "${unzipFolder}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${ec2apitoolsInstallFolder}")

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