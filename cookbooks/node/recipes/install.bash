#!/bin/bash -e

function installDependencies()
{
    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        installBuildEssential
        installPackages 'python'
    else
        installPackages 'gcc-c++' 'make' 'python'
    fi
}

function resetOwnerAndSymlinkLocalBin()
{
    chown -R "$(whoami):$(whoami)" "${NODE_INSTALL_FOLDER_PATH}"
    symlinkUsrBin "${NODE_INSTALL_FOLDER_PATH}/bin"
    symlinkListUsrBin "${NODE_INSTALL_FOLDER_PATH}/bin/node"
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${NODE_INSTALL_FOLDER_PATH}"

    # Install

    if [[ "${NODE_VERSION}" = 'latest' ]]
    then
        NODE_VERSION="$(getLatestVersionNumber)"
        local -r url="http://nodejs.org/dist/latest/node-${NODE_VERSION}-linux-x64.tar.gz"
    else
        if [[ "$(grep -o '^v' <<< "${NODE_VERSION}")" = '' ]]
        then
            NODE_VERSION="v${NODE_VERSION}"
        fi

        local -r url="http://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz"
    fi

    unzipRemoteFile "${url}" "${NODE_INSTALL_FOLDER_PATH}"

    # Reset Owner And Symlink Local Bin

    resetOwnerAndSymlinkLocalBin

    # Install NPM Packages

    local package

    for package in "${NODE_INSTALL_NPM_PACKAGES[@]}"
    do
        header "INSTALLING NODE PACKAGE ${package}"
        "${NODE_INSTALL_FOLDER_PATH}/bin/npm" install -g --prefix "${NODE_INSTALL_FOLDER_PATH}" "${package}"
    done

    # Reset Owner And Symlink Local Bin

    resetOwnerAndSymlinkLocalBin

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${NODE_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/node.sh.profile" '/etc/profile.d/node.sh' "${profileConfigData[@]}"

    # Clean Up

    local -r userHomeFolderPath="$(getCurrentUserHomeFolder)"

    rm -f -r "${userHomeFolderPath}/.cache" \
             "${userHomeFolderPath}/.npm"

    # Display Version

    displayVersion "Node Version : $(node --version)\nNPM Version  : $(npm --version)"

    umask '0077'
}

function getLatestVersionNumber()
{
    local -r versionPattern='v[[:digit:]]{1,2}\.[[:digit:]]{1,2}\.[[:digit:]]{1,3}'
    local -r shaSum256="$(getRemoteFileContent 'http://nodejs.org/dist/latest/SHASUMS256.txt.asc')"

    grep -E -o "node-${versionPattern}\.tar\.gz" <<< "${shaSum256}" | grep -E -o "${versionPattern}"
}

function main()
{
    local -r version="${1}"

    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING NODE'

    # Override Default Config

    if [[ "$(isEmptyString "${version}")" = 'false' ]]
    then
        NODE_VERSION="${version}"
    fi

    # Validation

    checkRequireLinuxSystem
    checkRequireRootUser

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"