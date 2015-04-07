#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${groovyJDKInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${groovyJDKInstallFolder}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${groovyInstallFolder}"

    # Install

    unzipRemoteFile "${groovyDownloadURL}" "${groovyInstallFolder}"

    local unzipFolder="$(find "${groovyInstallFolder}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(wc -l <<< "${unzipFolder}")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    local currentPath="$(pwd)"

    cd "${unzipFolder}"
    find '.' -maxdepth 1 -not -name '.' -exec mv '{}' "${groovyInstallFolder}" \;
    cd "${currentPath}"
    rm -f -r "${unzipFolder}"

    # Config Lib

    chown -R "$(whoami):$(whoami)" "${groovyInstallFolder}"
    ln -f -s "${groovyInstallFolder}/bin/groovy" '/usr/local/bin/groovy'

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${groovyInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/groovy.sh.profile" '/etc/profile.d/groovy.sh' "${profileConfigData[@]}"

    # Display Version

    info "$("${groovyInstallFolder}/bin/groovy" --version)"
}

function main()
{
    local installFolder="${1}"

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GROOVY'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        groovyInstallFolder="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"