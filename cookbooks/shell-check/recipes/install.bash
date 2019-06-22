#!/bin/bash -e

function installDependencies()
{
    installPackages 'cabal-install'
}

function install()
{
    umask '0022'

    local -r userHomeFolderPath="$(getCurrentUserHomeFolder)"

    rm -f -r "${userHomeFolderPath}/.cabal" "${userHomeFolderPath}/.ghc"
    initializeFolder "${SHELL_CHECK_CABAL_INSTALL_FOLDER_PATH}"

    cabal update
    cabal install 'shellcheck'

    moveFolderContent "${userHomeFolderPath}/.cabal" "${SHELL_CHECK_CABAL_INSTALL_FOLDER_PATH}"
    rm -f -r "${userHomeFolderPath}/.cabal" "${userHomeFolderPath}/.ghc"
    symlinkListUsrBin "${SHELL_CHECK_CABAL_INSTALL_FOLDER_PATH}/bin/shellcheck"

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/cabal.sh.profile" \
        '/etc/profile.d/cabal.sh' \
        '__INSTALL_FOLDER_PATH__' \
        "${SHELL_CHECK_CABAL_INSTALL_FOLDER_PATH}"

    displayVersion "$(shellcheck -V)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING SHELL-CHECK'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"