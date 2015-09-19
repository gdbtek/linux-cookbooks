#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'cabal-install'
}

function install()
{
    local -r userHomeFolderPath="$(getCurrentUserHomeFolder)"

    # Clean Up

    rm -f -r "${userHomeFolderPath}/.cabal" "${userHomeFolderPath}/.ghc"
    initializeFolder "${CABAL_INSTALL_FOLDER}"

    # Install

    cabal update
    cabal install 'shellcheck'

    moveFolderContent "${userHomeFolderPath}/.cabal" "${CABAL_INSTALL_FOLDER}"
    rm -f -r "${userHomeFolderPath}/.cabal" "${userHomeFolderPath}/.ghc"
    ln -f -s "${CABAL_INSTALL_FOLDER}/bin/shellcheck" '/usr/local/bin/shellcheck'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${CABAL_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/cabal.sh.profile" '/etc/profile.d/cabal.sh' "${profileConfigData[@]}"

    # Display Version

    header 'DISPLAYING VERSIONS'

    info "$("${CABAL_INSTALL_FOLDER}/bin/shellcheck" -V)"
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SHELL-CHECK'

    installDependencies
    install
    installCleanUp
}

main "${@}"