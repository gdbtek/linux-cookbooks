#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../lib/util.bash"

function cleanUp
{
    header 'CLEANING UP'

    deleteUser 'itcloud'
    rm -f -r '/home/ubuntu' '/opt/chef'
}

function displayNotice()
{
    local userLogin="${1}"

    header 'NOTICES'

    local userHome="$(getUserHomeFolder "${userLogin}")"

    checkExistFolder "${userHome}"

    info "-> Next is to copy this RSA to your git account :"
    cat "${userHome}/.ssh/id_rsa.pub"
    echo
}

function extendOPTPartition()
{
    local disk="${1}"
    local mountOn="${2}"
    local mounthdPartitionNumber="${3}"

    if [[ "$(existDisk "${disk}")" = 'true' ]]
    then
        if [[ "$(existDiskMount "${disk}${mounthdPartitionNumber}" "${mountOn}")" = 'false' ]]
        then
            rm -f -r "${mountOn}"
            "$(dirname "${BASH_SOURCE[0]}")/../../../../cookbooks/mount-hd/recipes/install.bash" "${disk}" "${mountOn}"
        else
            header 'EXTENDING OPT PARTITION'
            info "Already mounted '${disk}${mounthdPartitionNumber}' to '${mountOn}'\n"
            df -h -T
        fi
    else
        header 'EXTENDING OPT PARTITION'
        info "Extended volume '${disk}' not found"
    fi
}