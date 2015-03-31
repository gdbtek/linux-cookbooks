#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libffi-dev' 'libgdbm-dev' 'libreadline-dev' 'libssl-dev' 'zlib1g-dev'
}

function install()
{
    # Clean Up

    initializeFolder "${rubyInstallFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${rubyDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${rubyInstallFolder}"
    make
    make install
    symlinkLocalBin "${rubyInstallFolder}/bin"
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${rubyInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/ruby.sh.profile" '/etc/profile.d/ruby.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$(ruby --version)"
}

function main()
{
    local installFolder="${1}"

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING RUBY'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        rubyInstallFolder="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"