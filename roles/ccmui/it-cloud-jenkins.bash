#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    "${appPath}/../essential.bash"

    "${appPath}/../../cookbooks/mount-hd/recipes/install.bash" '/dev/sdb' '/opt/tomcat'
    "${appPath}/../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../cookbooks/jenkins/recipes/install.bash"
    "${appPath}/../../cookbooks/nginx/recipes/install.bash"
    "${appPath}/../../cookbooks/ps1/recipes/install.bash" 'ubuntu'

    generateUserSSHKey "${tomcatUserName}"
    displayNotice
}

function displayNotice()
{
    header 'NOTICES'

    info "-> Next is to copy this RSA to your git account:"
    cat ~${tomcatUserName}/.ssh/id_rsa.pub
}

main "${@}"