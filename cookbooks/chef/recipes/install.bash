#!/bin/bash -e

function install()
{
    umask '0022'

    checkExistURL "${CHEF_DOWNLOAD_URL}"
    debug "Downloading '${CHEF_DOWNLOAD_URL}'\n"
    curl -L "${CHEF_DOWNLOAD_URL}" --retry 12 --retry-delay 5 | bash -e
    info "\n$(knife -v)"

    umask '0077'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING CHEF'

    install
    installCleanUp
}

main "${@}"