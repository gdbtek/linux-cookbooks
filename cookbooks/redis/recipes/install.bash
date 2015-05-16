#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    initializeFolder "${redisInstallBinFolder}"
    initializeFolder "${redisInstallConfigFolder}"
    initializeFolder "${redisInstallDataFolder}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${redisDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}/src" -type f -not -name "*.sh" -perm -u+x -exec cp -f '{}' "${redisInstallBinFolder}" \;
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Server

    local -r serverConfigData=(
        '__INSTALL_DATA_FOLDER__' "${redisInstallDataFolder}"
        6379 "${redisPort}"
    )

    createFileFromTemplate "${appPath}/../templates/default/redis.conf.conf" "${redisInstallConfigFolder}/redis.conf" "${serverConfigData[@]}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_BIN_FOLDER__' "${redisInstallBinFolder}")

    createFileFromTemplate "${appPath}/../templates/default/redis.sh.profile" '/etc/profile.d/redis.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=(
        '__INSTALL_BIN_FOLDER__' "${redisInstallBinFolder}"
        '__INSTALL_CONFIG_FOLDER__' "${redisInstallConfigFolder}"
        '__USER_NAME__' "${redisUserName}"
        '__GROUP_NAME__' "${redisGroupName}"
        '__SOFT_NO_FILE_LIMIT__' "${redisSoftNoFileLimit}"
        '__HARD_NO_FILE_LIMIT__' "${redisHardNoFileLimit}"
    )

    createFileFromTemplate "${appPath}/../templates/default/redis.conf.upstart" "/etc/init/${redisServiceName}.conf" "${upstartConfigData[@]}"

    # Config System

    local -r overCommitMemoryConfig="vm.overcommit_memory=${redisVMOverCommitMemory}"

    appendToFileIfNotFound '/etc/sysctl.conf' "^\s*vm.overcommit_memory\s*=\s*${redisVMOverCommitMemory}\s*$" "\n${overCommitMemoryConfig}" 'true' 'true' 'true'
    sysctl "${overCommitMemoryConfig}"

    # Start

    addUser "${redisUserName}" "${redisGroupName}" 'false' 'true' 'false'
    chown -R "${redisUserName}:${redisGroupName}" "${redisInstallBinFolder}" "${redisInstallConfigFolder}" "${redisInstallDataFolder}"
    start "${redisServiceName}"

    # Display Version

    info "\n$("${redisInstallBinFolder}/redis-server" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING REDIS'

    checkRequirePort "${redisPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"