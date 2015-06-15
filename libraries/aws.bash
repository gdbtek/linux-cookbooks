#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/util.bash"

#####################
# GENERAL UTILITIES #
#####################

function getAllowedRegions()
{
    echo 'ap-northeast-1 ap-southeast-1 ap-southeast-2 eu-central-1 eu-west-1 sa-east-1 us-east-1 us-west-1 us-west-2'
}

function isValidRegion()
{
    local -r region="${1}"

    local -r allowedRegions=($(getAllowedRegions))

    isElementInArray "${region}" "${allowedRegions[@]}"
}

function unzipAWSS3RemoteFile()
{
    local -r downloadURL="${1}"
    local -r installFolder="${2}"
    local extension="${3}"

    # Find Extension

    local exExtension=''

    if [[ "$(isEmptyString "${extension}")" = 'true' ]]
    then
        extension="$(getFileExtension "${downloadURL}")"
        exExtension="$(rev <<< "${downloadURL}" | cut -d '.' -f 1-2 | rev)"
    fi

    # Unzip

    if [[ "$(grep -i '^tgz$' <<< "${extension}")" != '' || "$(grep -i '^tar\.gz$' <<< "${extension}")" != '' || "$(grep -i '^tar\.gz$' <<< "${exExtension}")" != '' ]]
    then
        debug "Downloading '${downloadURL}'"

        aws s3 cp "${downloadURL}" - | tar -C "${installFolder}" -x -z --strip 1 || \
        fatal "\n'${downloadURL}' does not exist or authentication failed"
    else
        fatal "\nFATAL : file extension '${extension}' not supported"
    fi
}

function updateInstanceName()
{
    local -r instanceName="${1}"

    header 'UPDATING INSTANCE NAME'

    info "${instanceName}"

    aws ec2 create-tags \
        --region "$(getInstanceRegion)" \
        --resources "$(getInstanceID)" \
        --tags "Key='Name',Value='${instanceName}'"
}

#######################
# META-DATA UTILITIES #
#######################

function getInstanceAvailabilityZone()
{
    curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/placement/availability-zone'
}

function getInstanceID()
{
    curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/instance-id'
}

################
# S3 UTILITIES #
################

function getInstanceRegion()
{
    local -r availabilityZone="$(getInstanceAvailabilityZone)"

    echo "${availabilityZone:0:${#availabilityZone} - 1}"
}

#######################
# USER-DATA UTILITIES #
#######################

function getUserDataValue()
{
    local -r key="$(escapeGrepSearchPattern "${1}")"

    trimString "$(
        curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/user-data' | \
        grep -E "^\s*${key}\s*=\s*" | \
        awk -F '=' '{ print $2 }'
    )"
}