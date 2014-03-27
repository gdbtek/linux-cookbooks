#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y build-essential
    apt-get install -y curl
}

function install()
{
    local currentPath="$(pwd)"
    local tempFolder="$(mktemp -d)"

    rm -rf "${installFolder}"
    mkdir -p "${installBinFolder}" "${installConfigFolder}" "${installDataFolder}"

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${tempFolder}"

    addSystemUser "${user}"
    cd "${tempFolder}"
    make
    find "${tempFolder}/src" -type f ! -name "*.sh" -perm -u+x -exec cp -f {} "${installBinFolder}" \;

    rm -rf "${tempFolder}"
    cd "${currentPath}"

    echo "export PATH=\"${installBinFolder}:\$PATH\"" > "${etcProfileFile}"
    cp -f "${appPath}/../files/upstart/redis.conf" "${etcInitFile}"
    cp -f "${appPath}/../files/conf/redis.conf" "${installConfigFolder}"

    if [[ "$(grep "^\s*fs.file-max\s*=\s*${fsFileMax}\s*$" "${systemConfigFile}")" = '' ]]
    then
        echo -e "\nfs.file-max = ${fsFileMax}" >> "${systemConfigFile}"
        sysctl fs.file-max="${fsFileMax}"
    fi

    if [[ "$(grep "^\s*vm.overcommit_memory\s*=\s*${vmOverCommitMemory}\s*$" "${systemConfigFile}")" = '' ]]
    then
        echo -e "\nvm.overcommit_memory = ${vmOverCommitMemory}" >> "${systemConfigFile}"
        sysctl vm.overcommit_memory="${vmOverCommitMemory}"
    fi

    start "$(getFileName "${etcInitFile}")"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING REDIS'

    checkRequireRootUser
    checkPortRequirement "${requirePorts[@]}"

    installDependencies
    install

    sleep 3
    displayOpenPorts
}

main "${@}"
