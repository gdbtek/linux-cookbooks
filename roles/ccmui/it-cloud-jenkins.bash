#!/bin/bash -e

function cleanUp
{
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
    rm -f -r '/opt'
    "${appPath}/../../cookbooks/mount-hd/recipes/install.bash" '/dev/sdb' '/opt'
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../lib/util.bash"
    source "${appPath}/../../cookbooks/tomcat/attributes/default.bash"

    extendOPTPartition

    "${appPath}/../essential.bash"
    "${appPath}/../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../cookbooks/jenkins/recipes/install.bash"
    "${appPath}/../../cookbooks/nginx/recipes/install.bash"
    "${appPath}/../../cookbooks/ps1/recipes/install.bash" "${tomcatUserName}"

    cleanUp
    generateUserSSHKey "${tomcatUserName}"
    displayNotice
}

main "${@}"