#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'cabal-install'
}

function install()
{
    # Clean Up

    rm -f -r ~/.cabal ~/.ghc
    initializeFolder "${CABAL_INSTALL_FOLDER}"

    # Install

    cabal update
    cabal install 'shellcheck'

    mv ~/.cabal/* "${CABAL_INSTALL_FOLDER}"
    rm -f -r ~/.cabal ~/.ghc
    ln -f -s "${CABAL_INSTALL_FOLDER}/bin/shellcheck" '/usr/local/bin/shellcheck'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${CABAL_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/default/cabal.sh.profile" '/etc/profile.d/cabal.sh' "${profileConfigData[@]}"

    # Display Version

    header 'DISPLAYING VERSIONS'

    info "$("${CABAL_INSTALL_FOLDER}/bin/shellcheck" -V)"
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SHELL-CHECK'

    installDependencies
    install
    installCleanUp
}

main "${@}"