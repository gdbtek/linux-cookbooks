#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    initializeFolder "${NODE_JS_INSTALL_FOLDER}"

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

    unzipRemoteFile "${url}" "${NODE_JS_INSTALL_FOLDER}"

    # Install NPM Packages

    local package=''

    for package in "${NODE_JS_INSTALL_NPM_PACKAGES[@]}"
    do
        header "INSTALLING NODE-JS PACKAGE ${package}"
        "${NODE_JS_INSTALL_FOLDER}/bin/npm" install "${package}" -g
    done

    # Reset Owner

    chown -R "$(whoami):$(whoami)" "${NODE_JS_INSTALL_FOLDER}"

    # Symlink Local Bin

    symlinkLocalBin "${NODE_JS_INSTALL_FOLDER}/bin"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${NODE_JS_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/node-js.sh.profile" '/etc/profile.d/node-js.sh' "${profileConfigData[@]}"

    # Clean Up

    local -r userHomeFolderPath="$(getCurrentUserHomeFolder)"

    rm -f -r "${userHomeFolderPath}/.cache" \
             "${userHomeFolderPath}/.node-gyp" \
             "${userHomeFolderPath}/.npm" \
             "${userHomeFolderPath}/.qws"

    # Display Version

    header 'DISPLAYING VERSIONS'

    info "Node Version: $(node --version)"
    info "NPM Version : $(npm --version)"
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

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NODE-JS'

    # Override Default Config

    if [[ "$(isEmptyString "${version}")" = 'false' ]]
    then
        NODE_JS_VERSION="${version}"
    fi

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        NODE_JS_INSTALL_FOLDER="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"