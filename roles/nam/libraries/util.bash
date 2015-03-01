#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function setupRepository()
{
    local repositoryPath="$(getUserHomeFolder "$(whoami)")/git/github.com/gdbtek"

    header 'SETUP GIT'

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

    local command='cd ~/git/github.com/gdbtek/ubuntu-cookbooks/cookbooks && git pull'

    appendToFileIfNotFound "$(getProfileFilePath "${userLogin}")" "${command}" "${command}" 'false' 'false' 'false'
}