#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function autoSudo()
{
    local -r userLogin="${1}"
    local -r profileFileName="${2}"

    header 'SETTING UP AUTO SUDO'

    local -r command='sudo su -l'

    appendToFileIfNotFound "$(getUserHomeFolder "${userLogin}")/${profileFileName}" "${command}" "${command}" 'false' 'false' 'true'
}

function setupRepository()
{
    local -r repositoryPath='/opt'

    header 'SETTING UP REPOSITORY'

    mkdir -p "${repositoryPath}"

    if [[ -d "${repositoryPath}/linux-cookbooks" ]]
    then
        cd "${repositoryPath}/linux-cookbooks"
        git pull
    else
        cd "${repositoryPath}"
        git clone 'https://github.com/gdbtek/linux-cookbooks.git'
    fi
}

function updateRepositoryOnLogin()
{
    local -r userLogin="${1}"

    header 'UPDATING REPOSITORY ON LOGIN'

    local -r command='cd /opt/linux-cookbooks/cookbooks && git pull'

    appendToFileIfNotFound "$(getProfileFilePath "${userLogin}")" "${command}" "${command}" 'false' 'false' 'true'
}