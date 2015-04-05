#!/bin/bash -e

function installDependencies()
{
    echo
    # installAptGetPackages 'build-essential' 'libffi-dev' 'libgdbm-dev' 'libreadline-dev' 'libssl-dev' 'zlib1g-dev'
}

function install()
{
    # Clean Up

    initializeFolder "${pythonInstallFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${pythonDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${pythonInstallFolder}"
    make
    make install
    symlinkLocalBin "${pythonInstallFolder}/bin"
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${pythonInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/python.sh.profile" '/etc/profile.d/python.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$(python --version)"
}

function main()
{
    local installFolder="${1}"

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PYTHON'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        pythonInstallFolder="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"