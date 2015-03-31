#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${awscliInstallFolder}"

    # Install

    unzipRemoteFile "${ec2amitoolsDownloadURL}" "${awscliInstallFolder}"

    local unzipFolder="$(find "${awscliInstallFolder}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

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
    find '.' -maxdepth 1 ! -name '.' -exec mv '{}' "${awscliInstallFolder}" \;
    cd "${currentPath}"
    rm -f -r "${unzipFolder}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${ec2amitoolsInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/ec2-ami-tools.sh.profile" '/etc/profile.d/ec2-ami-tools.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${awscliInstallFolder}/bin/aws" --version 2>&1)"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING EC2-AMI-TOOLS'

    install
    installCleanUp
}

main "${@}"