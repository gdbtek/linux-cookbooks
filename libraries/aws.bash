#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/util.bash"

#############################
# CLOUD-FORMATION UTILITIES #
#############################

function getStackIDByName()
{
    local -r stackName="${1}"

    checkNonEmptyString "${stackName}" 'undefined stack name'

    aws cloudformation describe-stacks \
        --output 'text' \
        --query 'Stacks[*].[StackId]' \
        --stack-name "${stackName}" \
    2> '/dev/null' || true
}

#################
# EC2 UTILITIES #
#################

function getLatestAMIIDByAMINamePattern()
{
    local -r amiNamePattern="${1}"

    checkNonEmptyString "${amiNamePattern}" 'undefined ami name pattern'

    aws ec2 describe-images \
        --filters "Name=architecture,Values=x86_64" \
                  "Name=image-type,Values=machine" \
                  "Name=is-public,Values=false" \
                  "Name=state,Values=available" \
                  "Name=name,Values=${amiNamePattern}" \
        --query 'sort_by(Images, &CreationDate)[-1].ImageId' |
    jq \
        --compact-output \
        --raw-output \
        '. // empty'
}

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

function getKeyPairFingerPrintByName()
{
    local -r keyPairName="${1}"

    checkNonEmptyString "${keyPairName}" 'undefined key pair name'

    aws ec2 describe-key-pairs \
        --key-name "${keyPairName}" 2> '/dev/null' |
    jq \
        --compact-output \
        --raw-output \
        '.["KeyPairs"] | .[0] | .["KeyFingerprint"] // empty'
}

function getSecurityGroupIDByName()
{
    local -r securityGroupName="${1}"

    checkNonEmptyString "${securityGroupName}" 'undefined security group name'

    aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=${securityGroupName}" |
    jq \
        --compact-output \
        --raw-output \
        '.["SecurityGroups"] | .[0] | .["GroupId"] // empty'
}

function getSecurityGroupIDsByNames()
{
    local -r securityGroupNames=("${@}")

    local securityGroupID=''
    local securityGroupIDs=''
    local securityGroupName=''

    for securityGroupName in "${securityGroupNames[@]}"
    do
        securityGroupID="$(getSecurityGroupIDByName "${securityGroupName}")"

        checkNonEmptyString "${securityGroupID}" "security group name '${securityGroupName}' not found"

        securityGroupIDs="$(printf '%s\n%s' "${securityGroupIDs}" "${securityGroupID}")"
    done

    echo "${securityGroupIDs}"
}

function revokeSecurityGroupIngress()
{
    local -r securityGroupID="${1}"
    local -r securityGroupName="${2}"

    checkNonEmptyString "${securityGroupID}" 'undefined security group ID'
    checkNonEmptyString "${securityGroupName}" 'undefined security group name'

    local -r ipPermissions="$(
        aws ec2 describe-security-groups \
            --filters "Name=group-name,Values=${securityGroupName}" |
        jq \
            --compact-output \
            --raw-output \
            '.["SecurityGroups"] | .[0] | .["IpPermissions"] // empty'
    )"

    if [[ "$(isEmptyString "${ipPermissions}")" = 'false' && "${ipPermissions}" != '[]' ]]
    then
        aws ec2 revoke-security-group-ingress \
            --group-id "${securityGroupID}" \
            --ip-permissions "${ipPermissions}"
    fi
}

function updateInstanceName()
{
    local -r instanceName="${1}"

    header 'UPDATING INSTANCE NAME'

    checkNonEmptyString "${instanceName}" 'undefined instance name'

    info "${instanceName}"

    aws ec2 create-tags \
        --region "$(getInstanceRegion)" \
        --resources "$(getInstanceID)" \
        --tags "Key='Name',Value='${instanceName}'"
}

#####################
# GENERAL UTILITIES #
#####################

function checkValidRegion()
{
    local -r region="${1}"

    if [[ "$(isValidRegion "${region}")" = 'false' ]]
    then
        fatal "\nFATAL : invalid region '${region}'"
    fi
}

function getAllowedRegions()
{
    echo 'ap-northeast-1 ap-northeast-2 ap-south-1 ap-southeast-1 ap-southeast-2 ca-central-1 eu-central-1 eu-west-1 eu-west-2 sa-east-1 us-east-1 us-east-2 us-west-1 us-west-2'
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

    checkNonEmptyString "${hostedZoneDomainName}" 'undefined hosted zone domain name'

    aws route53 list-hosted-zones-by-name \
        --dns-name "${hostedZoneDomainName}" |
    jq \
        --compact-output \
        --raw-output \
        '.["HostedZones"] | .[0] | .["Id"] // empty' |
    awk -F '/' '{ print $3 }'
}

################
# S3 UTILITIES #
################

function existS3Bucket()
{
    local -r bucketName="${1}"

    isEmptyString "$(aws s3api head-bucket --bucket "${bucketName}" 2>&1)"
}

function getAWSELBAccountID()
{
    local -r region="${1}"

    if [[ "${region}" = 'ap-northeast-1' ]]
    then
        echo '582318560864'
    elif [[ "${region}" = 'ap-northeast-2' ]]
    then
        echo '600734575887'
    elif [[ "${region}" = 'ap-south-1' ]]
    then
        echo '718504428378'
    elif [[ "${region}" = 'ap-southeast-1' ]]
    then
        echo '114774131450'
    elif [[ "${region}" = 'ap-southeast-2' ]]
    then
        echo '783225319266'
    elif [[ "${region}" = 'cn-north-1' ]]
    then
        echo '638102146993'
    elif [[ "${region}" = 'eu-central-1' ]]
    then
        echo '054676820928'
    elif [[ "${region}" = 'eu-west-1' ]]
    then
        echo '156460612806'
    elif [[ "${region}" = 'sa-east-1' ]]
    then
        echo '507241528517'
    elif [[ "${region}" = 'us-east-1' ]]
    then
        echo '127311923021'
    elif [[ "${region}" = 'us-east-2' ]]
    then
        echo '033677994240'
    elif [[ "${region}" = 'us-gov-west-1' ]]
    then
        echo '048591011584'
    elif [[ "${region}" = 'us-west-1' ]]
    then
        echo '027434742980'
    elif [[ "${region}" = 'us-west-2' ]]
    then
        echo '797873946194'
    else
        echo ''
    fi
}

#######################
# USER-DATA UTILITIES #
#######################

function getUserDataValue()
{
    local -r key="$(escapeGrepSearchPattern "${1}")"

    trimString "$(
        curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/user-data' |
        grep -E -o "^\s*${key}\s*=\s*.*$" |
        tail -1 |
        awk -F '=' '{ print $2 }'
    )"
}

#################
# VPC UTILITIES #
#################

function getAvailabilityZonesByVPCName()
{
    local -r vpcName="${1}"

    checkNonEmptyString "${vpcName}" 'undefined VPC name'

    local -r vpcID="$(getVPCIDByName "${vpcName}")"

    checkNonEmptyString "${vpcID}" 'undefined VPC ID'

    aws ec2 describe-subnets \
        --filters "Name=state,Values=available" \
                  "Name=vpc-id,Values=${vpcID}" \
        --query 'Subnets[*].AvailabilityZone' |
    jq \
        --compact-output \
        --raw-output \
        'unique | .[] // empty'
}

function getSubnetIDByName()
{
    local -r subnetName="${1}"

    aws ec2 describe-subnets \
        --filter "Name=tag:Name,Values=${subnetName}" |
    jq \
        --compact-output \
        --raw-output \
        '.["Subnets"] | .[0] | .["SubnetId"] // empty'
}

function getSubnetIDsByVPCName()
{
    local -r vpcName="${1}"
    local -r mapPublicIPOnLaunch="${2}"

    checkNonEmptyString "${vpcName}" 'undefined VPC name'
    checkTrueFalseString "${mapPublicIPOnLaunch}"

    local -r vpcID="$(getVPCIDByName "${vpcName}")"

    checkNonEmptyString "${vpcID}" 'undefined VPC ID'

    aws ec2 describe-subnets \
        --filters "Name=map-public-ip-on-launch,Values=${mapPublicIPOnLaunch}" \
                  "Name=state,Values=available" \
                  "Name=vpc-id,Values=${vpcID}" \
        --query 'Subnets[*].SubnetId' |
    jq \
        --compact-output \
        --raw-output \
        'unique | .[] // empty'
}

function getVPCIDByName()
{
    local -r vpcName="${1}"

    aws ec2 describe-vpcs \
        --filter "Name=tag:Name,Values=${vpcName}" |
    jq \
        --compact-output \
        --raw-output \
        '.["Vpcs"] | .[0] | .["VpcId"] // empty'
}