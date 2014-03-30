#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y build-essential
    apt-get install -y curl
}

function install()
{
    # Clean Up

    rm -rf "${installBinFolder}" "${installConfigFolder}" "${installDataFolder}"
    mkdir -p "${installBinFolder}" "${installConfigFolder}" "${installDataFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(mktemp -d)"

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${tempFolder}"
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

    updateTemplateFile "${appPath}/../files/conf/redis.conf" "${installConfigFolder}/redis.conf" "${serverConfigData[@]}"

    # Config Profile

    local profileConfigData=(
        '__INSTALL_BIN_FOLDER__' "${installBinFolder}"
    )

    updateTemplateFile "${appPath}/../files/profile/redis.sh" '/etc/profile.d/redis.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_BIN_FOLDER__' "${installBinFolder}"
        '__INSTALL_CONFIG_FOLDER__' "${installConfigFolder}"
        '__UID__' "${uid}"
        '__GID__' "${gid}"
    )

    updateTemplateFile "${appPath}/../files/upstart/redis.conf" "/etc/init/${serviceName}.conf" "${upstartConfigData[@]}"

    # Config System

    if [[ "$(grep "^\s*fs.file-max\s*=\s*${fsFileMax}\s*$" '/etc/sysctl.conf')" = '' ]]
    then
        echo -e "\nfs.file-max = ${fsFileMax}" >> '/etc/sysctl.conf'
        sysctl fs.file-max="${fsFileMax}"
    fi

    if [[ "$(grep "^\s*vm.overcommit_memory\s*=\s*${vmOverCommitMemory}\s*$" '/etc/sysctl.conf')" = '' ]]
    then
        echo -e "\nvm.overcommit_memory = ${vmOverCommitMemory}" >> '/etc/sysctl.conf'
        sysctl vm.overcommit_memory="${vmOverCommitMemory}"
    fi

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
