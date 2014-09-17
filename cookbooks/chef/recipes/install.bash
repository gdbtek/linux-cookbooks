#!/bin/bash -e

function install()
{
    checkExistURL "${chefDownloadURL}"
    debug "Downloading '${chefDownloadURL}'"
    curl -L "${chefDownloadURL}" | bash -e
    info "\n$(knife -v)"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING CHEF'

    install
    installCleanUp
}

main "${@}"