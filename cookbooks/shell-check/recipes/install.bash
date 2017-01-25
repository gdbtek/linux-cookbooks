#!/bin/bash -e

function installDependencies()
{
    installPackages 'cabal-install'
}

function install()
{
    umask '0022'

    local -r userHomeFolderPath="$(getCurrentUserHomeFolder)"

    # Clean Up

    rm -f -r "${userHomeFolderPath}/.cabal" "${userHomeFolderPath}/.ghc"
    initializeFolder "${SHELL_CHECK_CABAL_INSTALL_FOLDER_PATH}"

    # Install

    cabal update
    cabal install 'shellcheck'

    moveFolderContent "${userHomeFolderPath}/.cabal" "${SHELL_CHECK_CABAL_INSTALL_FOLDER_PATH}"
    rm -f -r "${userHomeFolderPath}/.cabal" "${userHomeFolderPath}/.ghc"
    ln -f -s "${SHELL_CHECK_CABAL_INSTALL_FOLDER_PATH}/bin/shellcheck" '/usr/local/bin/shellcheck'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${SHELL_CHECK_CABAL_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/cabal.sh.profile" '/etc/profile.d/cabal.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${SHELL_CHECK_CABAL_INSTALL_FOLDER_PATH}/bin/shellcheck" -V)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING SHELL-CHECK'

    installDependencies
    install
    installCleanUp
}

main "${@}"