#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function cleanUpITMess
{
    header 'CLEANING UP IT MESS'

    deleteUser 'itcloud'
    rm -f -r '/opt/chef' '/opt/lost+found'

    touch '/var/log/wtmp'

    rm -f '/etc/motd'
}

function displayNotice()
{
    local -r userLogin="${1}"

    header 'NOTICES'

    local -r userHome="$(getUserHomeFolder "${userLogin}")"

    checkExistFolder "${userHome}"
    checkExistFile "${userHome}/.ssh/id_rsa.pub"

    info '-> Next is to copy this RSA to your git account :'
    cat "${userHome}/.ssh/id_rsa.pub"
    echo
}