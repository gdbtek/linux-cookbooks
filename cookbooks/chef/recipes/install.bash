#!/bin/bash -e

function install()
{
    debug "Downloading '${chefDownloadURL}'"
    curl -L "${chefDownloadURL}" | bash
    info "\n$(knife -v)"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING CHEF'

    install
    installCleanUp
}

main "${@}"