#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'cabal-install'
}

function install()
{
    cabal update
    cabal install 'shellcheck'

    mv ~/.cabal "${cabalInstallFolder}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${cabalInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/cabal.sh.profile" '/etc/profile.d/cabal.sh' "${profileConfigData[@]}"

    # Display Version

    info "$("${cabalInstallFolder}/bin/shellcheck" -v)"
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