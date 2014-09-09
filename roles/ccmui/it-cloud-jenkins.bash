#!/bin/bash -e

function cleanUp
{
    header 'CLEANING UP'

    deleteUser 'itcloud'
    rm -f -r '/home/ubuntu' '/opt/chef'
}

function displayNotice()
{
    header 'NOTICES'

    info "-> Next is to copy this RSA to your git account :"
    cat "$(getUserHomeFolder "${tomcatUserName}")/.ssh/id_rsa.pub"
}

function extendOPTPartition()
{
    local disk='/dev/sdb'
    local mountOn='/opt'

    if [[ "$(existDisk "${disk}")" = 'true' ]]
    then
        if [[ "$(existDiskMount "${disk}${mounthdPartitionNumber}" "${mountOn}")" = 'false' ]]
        then
            rm -f -r "${mountOn}"
            "${appPath}/../../cookbooks/mount-hd/recipes/install.bash" "${disk}" "${mountOn}"
        else
            header 'EXTENDING OPT PARTITION'
            info "\nAlready mounted '${disk}${mounthdPartitionNumber}' to '${mountOn}'\n"
            df -h -T
        fi
    else
        header 'EXTENDING OPT PARTITION'
        info "\nExtended volume not found!"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../lib/util.bash"
    source "${appPath}/../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../cookbooks/tomcat/attributes/default.bash"

    extendOPTPartition

    "${appPath}/../essential.bash"
    "${appPath}/../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../cookbooks/jenkins/recipes/install.bash"
    "${appPath}/../../cookbooks/ps1/recipes/install.bash" "${tomcatUserName}"
    "${appPath}/../../cookbooks/nginx/recipes/install.bash"

    cleanUp
    generateUserSSHKey "${tomcatUserName}"
    displayNotice
}

main "${@}"