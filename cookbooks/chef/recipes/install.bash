#!/bin/bash -e

function install()
{
    checkExistURL "${CHEF_DOWNLOAD_URL}"
    debug "Downloading '${CHEF_DOWNLOAD_URL}'"
    curl -L "${CHEF_DOWNLOAD_URL}" --retry 3 --retry-delay 5 | bash -e
    info "\n$(knife -v)"
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING CHEF'

    install
    installCleanUp
}

main "${@}"