#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y build-essential
}

function install()
{
    # Clean Up

    rm -rf "${installBinFolder}" "${installConfigFolder}" "${installDataFolder}"
    mkdir -p "${installBinFolder}" "${installConfigFolder}" "${installDataFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${downloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}/src" -type f ! -name "*.sh" -perm -u+x -exec cp -f {} "${installBinFolder}" \;
    rm -rf "${tempFolder}"
    cd "${currentPath}"

    # Config Server

    local serverConfigData=(
        '__INSTALL_DATA_FOLDER__' "${installDataFolder}"
        6379 "${port}"
    )

    createFileFromTemplate "${appPath}/../files/conf/redis.conf" "${installConfigFolder}/redis.conf" "${serverConfigData[@]}"

    # Config Profile

    local profileConfigData=('__INSTALL_BIN_FOLDER__' "${installBinFolder}")

    createFileFromTemplate "${appPath}/../files/profile/redis.sh" '/etc/profile.d/redis.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_BIN_FOLDER__' "${installBinFolder}"
        '__INSTALL_CONFIG_FOLDER__' "${installConfigFolder}"
        '__UID__' "${uid}"
        '__GID__' "${gid}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/redis.conf" "/etc/init/${serviceName}.conf" "${upstartConfigData[@]}"

    # Config System - Open File Limit

    updateUserNoFileLimitConfig "${uid}" "${nofileLimit}"

    # Config System - Over Commit Memory

    local overCommitMemoryConfig="vm.overcommit_memory=${vmOverCommitMemory}"

    appendToFileIfNotFound '/etc/sysctl.conf' "^\s*vm.overcommit_memory\s*=\s*${vmOverCommitMemory}\s*$" "\n${overCommitMemoryConfig}" 'true' 'true'
    sysctl "${overCommitMemoryConfig}"

    # Start

    addSystemUser "${uid}" "${gid}"
    chown -R "${uid}":"${gid}" "${installBinFolder}" "${installConfigFolder}" "${installDataFolder}"
    start "${serviceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING REDIS'

    checkRequireRootUser
    checkPortRequirement "${port}"

    installDependencies
    install

    displayOpenPorts
}

main "${@}"
