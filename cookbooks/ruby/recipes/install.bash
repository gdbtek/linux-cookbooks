#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libffi-dev' 'libgdbm-dev' 'libreadline-dev' 'libssl-dev' 'zlib1g-dev'
}

function install()
{
    # Clean Up

    rm --force --recursive "${rubyInstallFolder}"
    mkdir --parents "${rubyInstallFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${rubyDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${rubyInstallFolder}"
    make
    make install
    symlinkLocalBin "${rubyInstallFolder}/bin"
    rm --force --recursive "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${rubyInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/ruby.sh.profile" '/etc/profile.d/ruby.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$(ruby --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING RUBY'

    installDependencies
    install
    installCleanUp
}

main "${@}"