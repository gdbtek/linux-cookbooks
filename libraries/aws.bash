#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/util.bash"

#################
# EC2 UTILITIES #
#################

function getInstanceAvailabilityZone()
{
    curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/placement/availability-zone'
}

function getInstanceID()
{
    curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/instance-id'
}

function getInstanceRegion()
{
    local -r availabilityZone="$(getInstanceAvailabilityZone)"

    checkNonEmptyString "${availabilityZone}" 'undefined availabilityZone'

    echo "${availabilityZone:0:${#availabilityZone} - 1}"
}

function getSecurityGroupIDByName()
{
    local -r securityGroupName="${1}"

    aws ec2 describe-security-groups --filters "Name=group-name,Values=${securityGroupName}" | \
    jq \
        --compact-output \
        --raw-output \
        '.["SecurityGroups"] | .[0] | .["GroupId"] // empty'
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

#####################
# GENERAL UTILITIES #
#####################

function getAllowedRegions()
{
    echo 'ap-northeast-1 ap-northeast-2 ap-southeast-1 ap-southeast-2 eu-central-1 eu-west-1 sa-east-1 us-east-1 us-west-1 us-west-2'
}

function getRegionFromRecordSetAliasTargetDNSName()
{
    local -r recordSetAliasTargetDNSName="${1}"

    # Regions

    local -r allowedRegions=($(getAllowedRegions))
    local region=''

    for region in "${allowedRegions[@]}"
    do
        if [[ "$(grep -F -i -o "${region}" <<< "${recordSetAliasTargetDNSName}")" != '' ]]
        then
            echo "${region}" && return 0
        fi
    done
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
        debug "Downloading '${downloadURL}'\n"

        aws s3 cp "${downloadURL}" - | tar -C "${installFolder}" -x -z --strip 1 ||
        fatal "\nFATAL : '${downloadURL}' does not exist or authentication failed"
    else
        fatal "\nFATAL : file extension '${extension}' not supported"
    fi
}

######################
# ROUTE-53 UTILITIES #
######################

function getHostedZoneIDByDomainName()
{
    local -r hostedZoneDomainName="${1}"

    aws route53 list-hosted-zones-by-name --dns-name "${hostedZoneDomainName}" | \
    jq \
        --compact-output \
        --raw-output \
        '.["HostedZones"] | .[0] | .["Id"] // empty' | \
    awk -F '/' '{ print $3 }'
}

#######################
# USER-DATA UTILITIES #
#######################

function getUserDataValue()
{
    local -r key="$(escapeGrepSearchPattern "${1}")"

    trimString "$(
        curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/user-data' | \
        grep -E -o "^\s*${key}\s*=\s*.*$" | \
        tail -1 | \
        awk -F '=' '{ print $2 }'
    )"
}