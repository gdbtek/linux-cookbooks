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

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/ruby.sh.profile" '/etc/profile.d/ruby.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(ruby --version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING RUBY'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"