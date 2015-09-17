#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libffi-dev' 'libgdbm-dev' 'libreadline-dev' 'libssl-dev' 'zlib1g-dev'
}

function install()
{
    # Clean Up

    initializeFolder "${RUBY_INSTALL_FOLDER}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${RUBY_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${RUBY_INSTALL_FOLDER}"
    make
    make install
    symlinkLocalBin "${RUBY_INSTALL_FOLDER}/bin"
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${RUBY_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/ruby.sh.profile" '/etc/profile.d/ruby.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$(ruby --version)"
}

function main()
{
    local -r installFolder="${1}"

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING RUBY'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        RUBY_INSTALL_FOLDER="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"