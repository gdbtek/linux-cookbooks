#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function setupGIT()
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