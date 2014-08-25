#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    rm -f -r "${redisInstallBinFolder}" "${redisInstallConfigFolder}" "${redisInstallDataFolder}"
    mkdir -p "${redisInstallBinFolder}" "${redisInstallConfigFolder}" "${redisInstallDataFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${redisDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}/src" -type f ! -name "*.sh" -perm -u+x -exec cp -f {} "${redisInstallBinFolder}" \;
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Server

    local serverConfigData=(
        '__INSTALL_DATA_FOLDER__' "${redisInstallDataFolder}"
        6379 "${redisPort}"
    )

    createFileFromTemplate "${appPath}/../templates/default/redis.conf.conf" "${redisInstallConfigFolder}/redis.conf" "${serverConfigData[@]}"

    # Config Profile

    local profileConfigData=('__INSTALL_BIN_FOLDER__' "${redisInstallBinFolder}")

    createFileFromTemplate "${appPath}/../templates/default/redis.sh.profile" '/etc/profile.d/redis.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_BIN_FOLDER__' "${redisInstallBinFolder}"
        '__INSTALL_CONFIG_FOLDER__' "${redisInstallConfigFolder}"
        '__USER_NAME__' "${redisUserName}"
        '__GROUP_NAME__' "${redisGroupName}"
        '__SOFT_NO_FILE_LIMIT__' "${redisSoftNoFileLimit}"
        '__HARD_NO_FILE_LIMIT__' "${redisHardNoFileLimit}"
    )

    createFileFromTemplate "${appPath}/../templates/default/redis.conf.upstart" "/etc/init/${redisServiceName}.conf" "${upstartConfigData[@]}"

    # Config System

    local overCommitMemoryConfig="vm.overcommit_memory=${redisVMOverCommitMemory}"

    appendToFileIfNotFound '/etc/sysctl.conf' "^\s*vm.overcommit_memory\s*=\s*${redisVMOverCommitMemory}\s*$" "\n${overCommitMemoryConfig}" 'true' 'true'
    sysctl "${overCommitMemoryConfig}"

    # Start

    addSystemUser "${redisUserName}" "${redisGroupName}"
    chown -R "${redisUserName}":"${redisGroupName}" "${redisInstallBinFolder}" "${redisInstallConfigFolder}" "${redisInstallDataFolder}"
    start "${redisServiceName}"

    # Display Version

    info "\n$("${redisInstallBinFolder}/redis-server" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
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