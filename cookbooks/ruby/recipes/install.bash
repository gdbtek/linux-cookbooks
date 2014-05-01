#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y build-essential
    apt-get install -y libgdbm-dev
    apt-get install -y libssl-dev
}

function install()
{
    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${downloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${installFolder}"
    make
    make install
    symlinkLocalBin "${installFolder}/bin"
    rm -rf "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/profile/ruby.sh" '/etc/profile.d/ruby.sh' "${profileConfigData[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING RUBY'

    checkRequireRootUser

    installDependencies
    install
}

main "${@}"
