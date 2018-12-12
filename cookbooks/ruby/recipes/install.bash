#!/bin/bash -e

function installDependencies()
{
    installBuildEssential

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        installPackages 'libffi-dev' 'libgdbm-dev' 'libreadline-dev' 'libssl-dev' 'zlib1g-dev'
    fi
}

function install()
{
    umask '0022'

    # Install

    compileAndInstallFromSource "${RUBY_DOWNLOAD_URL}" "${RUBY_INSTALL_FOLDER_PATH}" "${RUBY_INSTALL_FOLDER_PATH}/bin" "$(whoami)"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${RUBY_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/ruby.sh.profile" '/etc/profile.d/ruby.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(ruby --version)"

    umask '0077'
}

function main()
{
    local -r installFolder="${1}"

    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING RUBY'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        RUBY_INSTALL_FOLDER_PATH="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"