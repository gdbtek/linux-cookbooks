#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../lib/util.bash"

    cd "${appPath}/../../cookbooks/tomcat/recipes"
    source "${appPath}/../../cookbooks/tomcat/attributes/default.bash"

    "${appPath}/../essential.bash"

    "${appPath}/../../cookbooks/mount-hd/recipes/install.bash" '/dev/sdb' "${tomcatInstallFolder}"
    "${appPath}/../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../cookbooks/jenkins/recipes/install.bash"
    "${appPath}/../../cookbooks/nginx/recipes/install.bash"
    "${appPath}/../../cookbooks/ps1/recipes/install.bash" "${tomcatUserName}"

    cleanUp
    generateUserSSHKey "${tomcatUserName}"
    displayNotice
}

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

main "${@}"