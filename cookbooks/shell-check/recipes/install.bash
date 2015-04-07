#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'cabal-install'
}

function install()
{
    # Clean Up

    rm -f -r ~/.cabal
    initializeFolder "${cabalInstallFolder}"

    # Install

    cabal update
    cabal install 'shellcheck'

    mv ~/.cabal/* "${cabalInstallFolder}"
    rm -f -r ~/.cabal

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${cabalInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/cabal.sh.profile" '/etc/profile.d/cabal.sh' "${profileConfigData[@]}"

    # Display Version

    header 'DISPLAYING VERSIONS'

    info "$("${cabalInstallFolder}/bin/shellcheck" -V)"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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