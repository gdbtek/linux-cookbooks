#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function autoSudo()
{
    local userLogin="${1}"
    local profileFileName="${2}"

    header 'AUTO SUDO'

    local command='sudo su -'

    appendToFileIfNotFound "$(getUserHomeFolder "${userLogin}")/${profileFileName}" "${command}" "${command}" 'false' 'false' 'true'
}

function setupRepository()
{
    local repositoryPath="$(getCurrentUserHomeFolder)/git/github.com/gdbtek"

    header 'SETUP REPOSITORY'

    mkdir -p "${repositoryPath}"

    if [[ -d "${repositoryPath}/ubuntu-cookbooks" ]]
    then
        cd "${repositoryPath}/ubuntu-cookbooks"
        git pull
    else
        cd "${repositoryPath}"
        git clone 'https://github.com/gdbtek/ubuntu-cookbooks.git'
    fi
}

function updateRepositoryOnLogin()
{
    local userLogin="${1}"

    header 'UPDATE REPOSITORY ON LOGIN'

    local command='cd ~/git/github.com/gdbtek/ubuntu-cookbooks/cookbooks && git pull'

    appendToFileIfNotFound "$(getProfileFilePath "${userLogin}")" "${command}" "${command}" 'false' 'false' 'true'
}