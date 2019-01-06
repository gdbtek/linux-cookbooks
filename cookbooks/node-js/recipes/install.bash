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
    chown -R "$(whoami):$(whoami)" "${NODE_JS_INSTALL_FOLDER_PATH}"
    symlinkLocalBin "${NODE_JS_INSTALL_FOLDER_PATH}/bin"
    ln -f -s "${NODE_JS_INSTALL_FOLDER_PATH}/bin/node" '/usr/bin/node'
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${NODE_JS_INSTALL_FOLDER_PATH}"

    # Install

    if [[ "${NODE_JS_VERSION}" = 'latest' ]]
    then
        NODE_JS_VERSION="$(getLatestVersionNumber)"
        local -r url="http://nodejs.org/dist/latest/node-${NODE_JS_VERSION}-linux-x64.tar.gz"
    else
        if [[ "$(grep -o '^v' <<< "${NODE_JS_VERSION}")" = '' ]]
        then
            NODE_JS_VERSION="v${NODE_JS_VERSION}"
        fi

        local -r url="http://nodejs.org/dist/${NODE_JS_VERSION}/node-${NODE_JS_VERSION}-linux-x64.tar.gz"
    fi

    unzipRemoteFile "${url}" "${NODE_JS_INSTALL_FOLDER_PATH}"

    # Reset Owner And Symlink Local Bin

    resetOwnerAndSymlinkLocalBin

    # Install NPM Packages

    local package=''

    for package in "${NODE_JS_INSTALL_NPM_PACKAGES[@]}"
    do
        header "INSTALLING NODE-JS PACKAGE ${package}"
        "${NODE_JS_INSTALL_FOLDER_PATH}/bin/npm" install -g --prefix "${NODE_JS_INSTALL_FOLDER_PATH}" "${package}"
    done

    # Reset Owner And Symlink Local Bin

    resetOwnerAndSymlinkLocalBin

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${NODE_JS_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/node-js.sh.profile" '/etc/profile.d/node-js.sh' "${profileConfigData[@]}"

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
    local -r installFolder="${2}"

    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING NODE-JS'

    # Override Default Config

    if [[ "$(isEmptyString "${version}")" = 'false' ]]
    then
        NODE_JS_VERSION="${version}"
    fi

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        NODE_JS_INSTALL_FOLDER_PATH="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"