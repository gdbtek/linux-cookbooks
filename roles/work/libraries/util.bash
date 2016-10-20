#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function cleanUpMess
{
    header 'CLEANING UP MESS'

    rm -f '/etc/motd'
}

function displayNotice()
{
    local -r userLogin="${1}"

    header 'DISPLAYING NOTICES'

    local -r userHome="$(getUserHomeFolder "${userLogin}")"

    checkExistFolder "${userHome}"
    checkExistFile "${userHome}/.ssh/id_rsa.pub"

    info '-> Next is to copy this RSA to your git account :'
    cat "${userHome}/.ssh/id_rsa.pub"
    echo
}

function configUsersSSH()
{
    local -r users=("${@}")

    header 'CONFIGURING USERS SSH'

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Each User

    local user=''

    for user in "${users[@]}"
    do
        if [[ "$(existUserLogin "${user}")" = 'true' ]]
        then
            echo -e "configurig ssh for user '\033[1;32m${user}\033[0m'"

            addUserAuthorizedKey "${user}" "$(id -g -n "${user}")" "$(cat "${appFolderPath}/../files/authorized_keys")"
            addUserSSHKnownHost "${user}" "$(id -g -n "${user}")" "$(cat "${appFolderPath}/../files/known_hosts")"
        else
            warn "WARN : user '${user}' not found"
        fi
    done
}