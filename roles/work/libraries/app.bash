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
    local -r isMasterMachine="${2}"

    header 'DISPLAYING NOTICES'

    local -r userHome="$(getUserHomeFolder "${userLogin}")"

    checkExistFolder "${userHome}"
    checkExistFile "${userHome}/.ssh/id_rsa.pub"

    if [[ "${isMasterMachine}" = 'true' ]]
    then
        info '-> Next is to copy this RSA to your GIT SSH and JENKINS SLAVES Tomcat user authorized_keys file :'
    else
        info '-> Next is to copy this RSA to your GIT SSH :'
    fi

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
    local userHome=''

    for user in "${users[@]}"
    do
        userHome="$(getUserHomeFolder "${user}")"

        if [[ "$(existUserLogin "${user}")" = 'true' && -d "${userHome}" ]]
        then
            rm -f -r "$(getUserHomeFolder "${user}")/.ssh"

            addUserAuthorizedKey "${user}" "$(getUserGroupName "${user}")" "$(cat "${appFolderPath}/../files/authorized_keys")"
            addUserSSHKnownHost "${user}" "$(getUserGroupName "${user}")" "$(cat "${appFolderPath}/../files/known_hosts")"
        else
            warn "WARN : user '${user}' not found or home directory does not exist"
        fi
    done
}