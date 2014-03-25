#!/bin/bash

function formatPath
{
    local string="${1}"

    while [[ "$(echo "${string}" | grep -F '//')" != '' ]]
    do
        string="$(echo "${string}" | sed -e 's/\/\/*/\//g')"
    done

    echo "${string}" | sed -e 's/\/$//g'
}

function header
{
    echo -e "\n\033[1;33m>>>>>>>>>> \033[1;4;35m${1}\033[0m \033[1;33m<<<<<<<<<<\033[0m\n"
}

function error()
{
    echo -e "\033[1;31m${1}\033[0m" 1>&2
}

function fatal()
{
    error "${1}"
    exit 1
}

function trimString()
{
    echo "${1}" | sed -e 's/^ *//g' -e 's/ *$//g'
}

function isEmptyString()
{
    if [[ "$(trimString ${1})" = '' ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function addSystemUser()
{
    adduser --system --no-create-home --disabled-login --disabled-password --group "${1}" >> /dev/null 2>&1
}

function checkRequireRootUser
{
    if [[ "$(whoami)" != 'root' ]]
    then
        fatal "ERROR: please run this program as 'root'"
    fi
}

function getFileName()
{
    local fullFileName="$(basename "${1}")"

    echo "${fullFileName%.*}"
}

function displayOpenPorts
{
    header 'LIST OPEN PORTS'

    lsof -P -i | grep ' (LISTEN)$' | sort
}
