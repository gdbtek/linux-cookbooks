#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/util.bash"

##############################
# AUTO SCALE GROUP UTILITIES #
##############################

function getAutoScaleGroupNameByStackName()
{
    local -r stackName="${1}"

    checkNonEmptyString "${stackName}" 'undefined stack name'

    aws autoscaling describe-auto-scaling-groups \
        --no-cli-pager \
        --output 'json' |
    jq \
        --arg jqStackName "${stackName}" \
        --compact-output \
        --raw-output \
        --sort-keys \
        '.["AutoScalingGroups"] |
        .[] |
        .["Tags"] |
        .[] |
        select(.["ResourceType"] == "auto-scaling-group") |
        select(.["Key"] == "aws:cloudformation:stack-name") |
        select(.["Value"] == $jqStackName) |
        .["ResourceId"] // empty'
}

function getInstanceOrderIndexInAutoScaleInstancesByEIPs()
{
    local -r stackName="${1}"
    local instanceID="${2}"
    local -r elasticPublicIPs=("${@:3}")

    # Set Default Value

    if [[ "$(isEmptyString "${instanceID}")" = 'true' ]]
    then
        instanceID="$(getInstanceID 'false')"
    fi

    # Validate Values

    checkNonEmptyString "${stackName}" 'undefined stack name'
    checkNonEmptyString "${instanceID}" 'undefined instance id'
    checkNonEmptyArray 'undefined elastic public ips' "${elasticPublicIPs[@]}"

    # Find Order Index

    local -r autoScaleGroupName="$(getAutoScaleGroupNameByStackName "${stackName}")"

    checkNonEmptyString "${autoScaleGroupName}" 'undefined auto scale group name'

    local -r autoScaleInstanceIDs=($(
        aws ec2 describe-instances \
            --filters \
                'Name=instance-state-name,Values=pending,running' \
                "Name=tag:aws:autoscaling:groupName,Values=${autoScaleGroupName}" \
                "Name=tag:aws:cloudformation:stack-name,Values=${stackName}" \
            --no-cli-pager \
            --output 'json' \
            --query 'sort_by(Reservations[*].Instances[], &LaunchTime)[*].{
                "InstanceId": InstanceId,
                "PublicIpAddress": PublicIpAddress
            }' |
        jq \
            --argjson jqElasticPublicIPs "$(printf '%s\n' "${elasticPublicIPs[@]}" | jq -R | jq -s)" \
            --compact-output \
            --raw-output \
            '.[] | select(.["PublicIpAddress"] | IN($jqElasticPublicIPs[]) | not) | .["InstanceId"] // empty'
    ))

    local i=0

    for ((i = 0; i < ${#autoScaleInstanceIDs[@]}; i = i + 1))
    do
        if [[ "${autoScaleInstanceIDs[i]}" = "${instanceID}" ]]
        then
            echo "${i}"
            i="$((${#autoScaleInstanceIDs[@]}))"
        fi
    done
}

function getInstanceOrderIndexInAutoScaleInstancesByENIs()
{
    local -r stackName="${1}"
    local instanceID="${2}"
    local -r elasticNetworkInterfaceIDs=("${@:3}")

    # Set Default Value

    if [[ "$(isEmptyString "${instanceID}")" = 'true' ]]
    then
        instanceID="$(getInstanceID 'false')"
    fi

    # Validate Values

    checkNonEmptyString "${stackName}" 'undefined stack name'
    checkNonEmptyString "${instanceID}" 'undefined instance id'
    checkNonEmptyArray 'undefined elastic network interface ids' "${elasticNetworkInterfaceIDs[@]}"

    # Filter Network Interface IDs By :
    #     Status Available
    #     Instance Subnet ID
    #     Within Network Interface ID List From Configurations

    local -r instanceSubnetID="$(getInstanceSubnetID)"

    checkNonEmptyString "${instanceSubnetID}" 'undefined instance subnet id'

    local -r filterElasticNetworkInterfaceIDs=($(
        aws ec2 describe-network-interfaces \
            --filters \
                'Name=status,Values=available' \
                "Name=subnet-id,Values=${instanceSubnetID}" \
            --no-cli-pager \
            --output 'json' \
            --query 'sort_by(NetworkInterfaces[*], &NetworkInterfaceId)[*]' |
        jq \
            --argjson jqElasticNetworkInterfaceIDs "$(printf '%s\n' "${elasticNetworkInterfaceIDs[@]}" | jq -R | jq -s)" \
            --compact-output \
            --raw-output \
            '.[] | select(.["NetworkInterfaceId"] | IN($jqElasticNetworkInterfaceIDs[])) | .["NetworkInterfaceId"] // empty'
    ))

    # Get Instance ID List Has :
    #     Instance Subnet ID
    #     Auto Scale Group Name
    #     Stack Name
    #     NOT IN Filter Elastic Network Interface IDs

    local -r autoScaleGroupName="$(getAutoScaleGroupNameByStackName "${stackName}")"

    checkNonEmptyString "${autoScaleGroupName}" 'undefined auto scale group name'

    local -r autoScaleInstanceIDs=($(
        aws ec2 describe-instances \
            --filters \
                'Name=instance-state-name,Values=pending,running' \
                "Name=network-interface.subnet-id,Values=${instanceSubnetID}" \
                "Name=tag:aws:autoscaling:groupName,Values=${autoScaleGroupName}" \
                "Name=tag:aws:cloudformation:stack-name,Values=${stackName}" \
            --no-cli-pager \
            --output 'json' \
            --query 'sort_by(Reservations[*].Instances[], &LaunchTime)[*]' |
        jq \
            --argjson jqFilterElasticNetworkInterfaceIDs "$(printf '%s\n' "${filterElasticNetworkInterfaceIDs[@]}" | jq -R | jq -s)" \
            --compact-output \
            --raw-output \
            '.[] | select(.["NetworkInterfaces"] | all(.["NetworkInterfaceId"] != ($jqFilterElasticNetworkInterfaceIDs[]))) | .["InstanceId"] // empty'
    ))

    # Find Instance Order Index

    local i=0

    for ((i = 0; i < ${#autoScaleInstanceIDs[@]}; i = i + 1))
    do
        if [[ "${autoScaleInstanceIDs[i]}" = "${instanceID}" ]]
        then
            echo "${i}:$(arrayToStringWithDelimiter ' ' "${filterElasticNetworkInterfaceIDs[@]}")"
            i="$((${#autoScaleInstanceIDs[@]}))"
        fi
    done
}

#############################
# CLOUD-FORMATION UTILITIES #
#############################

function getStackIDByName()
{
    local -r stackName="${1}"

    checkNonEmptyString "${stackName}" 'undefined stack name'

    aws cloudformation describe-stacks \
        --no-cli-pager \
        --output 'text' \
        --query 'Stacks[*].[StackId]' \
        --stack-name "${stackName}" \
    2> '/dev/null' || true
}

#################
# EC2 UTILITIES #
#################

function associateAvailableElasticPublicIPToInstanceID()
{
    local -r region="${1}"
    local -r instanceID="${2}"
    local -r elasticPublicIPs=("${@:3}")

    local -r availableElasticPublicIP="$(getAvailableElasticPublicIP "${region}" "${elasticPublicIPs[@]}")"

    if [[ "$(isEmptyString "${availableElasticPublicIP}")" = 'false' ]]
    then
        associateElasticPublicIPToInstanceID "${region}" "${instanceID}" "${availableElasticPublicIP}"
    fi
}

function associateElasticPublicIPToInstanceID()
{
    local region="${1}"
    local instanceID="${2}"
    local -r elasticPublicIP="${3}"

    # Set Default Value

    if [[ "$(isEmptyString "${region}")" = 'true' ]]
    then
        region="$(getInstanceRegion 'false')"
    fi

    if [[ "$(isEmptyString "${instanceID}")" = 'true' ]]
    then
        instanceID="$(getInstanceID 'false')"
    fi

    # Validate Values

    checkValidRegion "${region}"
    checkNonEmptyString "${instanceID}" 'undefined instance id'
    checkNonEmptyString "${elasticPublicIP}" 'undefined elastic public ip'

    # Associate Elastic Public IP

    local -r allocationID="$(getEC2ElasticAllocationIDByElasticPublicIP "${region}" "${elasticPublicIP}")"

    checkNonEmptyString "${allocationID}" 'undefined allocation id'

    aws ec2 associate-address \
        --allocation-id "${allocationID}" \
        --allow-reassociation \
        --instance-id "${instanceID}" \
        --no-cli-pager \
        --region "${region}"
}

function attachNetworkInterfaceIDToInstanceID()
{
    local instanceID="${1}"
    local -r elasticNetworkInterfaceIDs=("${@:2}")

    # Set Default Value

    if [[ "$(isEmptyString "${instanceID}")" = 'true' ]]
    then
        instanceID="$(getInstanceID 'false')"
    fi

    # Validate Values

    checkNonEmptyString "${instanceID}" 'undefined instance id'
    checkNonEmptyArray 'undefined elastic network interface ids' "${elasticNetworkInterfaceIDs[@]}"

    # Attach Network Interface

    local -r elasticNetworkInterfaceID="$(
        aws ec2 describe-network-interfaces \
            --filters 'Name=status,Values=available' \
            --network-interface-ids "${elasticNetworkInterfaceIDs[@]}" \
            --no-cli-pager \
            --output 'json' |
        jq \
            --compact-output \
            --raw-output \
            '.["NetworkInterfaces"] | first | .["NetworkInterfaceId"] // empty'
    )"

    checkNonEmptyString "${elasticNetworkInterfaceID}" 'undefined elastic network interface id'

    aws ec2 attach-network-interface \
        --device-index '1' \
        --instance-id "${instanceID}" \
        --network-interface-id "${elasticNetworkInterfaceID}" \
        --no-cli-pager
}

function getAvailableElasticPublicIP()
{
    local -r region="${1}"
    local -r elasticPublicIPs=("${@:2}")

    local i=0

    for ((i = 0; i < ${#elasticPublicIPs[@]}; i = i + 1))
    do
        if [[ "$(getEC2ElasticAllocationIDByElasticPublicIP "${region}" "${elasticPublicIPs[i]}")" != '' &&
              "$(getEC2ElasticAssociationIDByElasticPublicIP "${region}" "${elasticPublicIPs[i]}")" = '' ]]
        then
            echo "${elasticPublicIPs[i]}"
            i="$((${#elasticPublicIPs[@]}))"
        fi
    done
}

function getEC2ElasticAllocationIDByElasticPublicIP()
{
    local region="${1}"
    local -r elasticPublicIP="${2}"

    # Set Default Value

    if [[ "$(isEmptyString "${region}")" = 'true' ]]
    then
        region="$(getInstanceRegion 'false')"
    fi

    # Validate Values

    checkValidRegion "${region}"
    checkNonEmptyString "${elasticPublicIP}" 'undefined elastic public ip'

    # Get EC2 Elastic Allocation ID

    aws ec2 describe-addresses \
        --no-cli-pager \
        --output 'text' \
        --public-ips "${elasticPublicIP}" \
        --query 'Addresses[0].[AllocationId]' \
        --region "${region}" \
    2> '/dev/null'
}

function getEC2ElasticAssociationIDByElasticPublicIP()
{
    local region="${1}"
    local -r elasticPublicIP="${2}"

    # Set Default Value

    if [[ "$(isEmptyString "${region}")" = 'true' ]]
    then
        region="$(getInstanceRegion 'false')"
    fi

    # Validate Values

    checkValidRegion "${region}"
    checkNonEmptyString "${elasticPublicIP}" 'undefined elastic public ip'

    # Get EC2 Elastic Association ID

    aws ec2 describe-addresses \
        --no-cli-pager \
        --output 'text' \
        --public-ips "${elasticPublicIP}" \
        --query 'Addresses[0].[AssociationId]' \
        --region "${region}" \
    2> '/dev/null' |
    grep -i -v '^None$'
}

function getEC2PrivateIpAddressByInstanceID()
{
    local region="${1}"
    local -r instanceID="${2}"

    # Set Default Value

    if [[ "$(isEmptyString "${region}")" = 'true' ]]
    then
        region="$(getInstanceRegion 'false')"
    fi

    # Get Private IP

    if [[ "$(isEmptyString "${instanceID}")" = 'true' ]]
    then
        curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/local-ipv4'
    else
        aws ec2 describe-instances \
            --instance-id "${instanceID}" \
            --no-cli-pager \
            --output 'text' \
            --query 'Reservations[*].Instances[*].PrivateIpAddress' \
            --region "${region}"
    fi
}

function getEC2PrivateIpAddresses()
{
    local namePattern="${1}"
    local excludeCurrentInstance="${2}"
    local vpcID="${3}"
    local region="${4}"

    # Set Default Values

    if [[ "$(isEmptyString "${namePattern}")" = 'true' ]]
    then
        namePattern='*'
    fi

    if [[ "${excludeCurrentInstance}" != 'true' ]]
    then
        excludeCurrentInstance='false'
    fi

    if [[ "$(isEmptyString "${vpcID}")" = 'true' ]]
    then
        vpcID="$(getInstanceVPCID)"
    fi

    if [[ "$(isEmptyString "${region}")" = 'true' ]]
    then
        region="$(getInstanceRegion 'false')"
    fi

    # Get Instances

    local -r instances=($(
        aws ec2 describe-instances \
            --filters \
                'Name=instance-state-name,Values=pending,running' \
                "Name=tag:Name,Values=${namePattern}" \
                "Name=vpc-id,Values=${vpcID}" \
            --no-cli-pager \
            --output 'text' \
            --query 'Reservations[*].Instances[*].PrivateIpAddress' \
            --region "${region}"
    ))

    if [[ "${excludeCurrentInstance}" = 'true' ]]
    then
        excludeElementFromArray "$(getEC2PrivateIpAddressByInstanceID '' '')" "${instances[@]}"
    else
        echo "${instances[@]}"
    fi
}

function getKeyPairFingerPrintByName()
{
    local -r keyPairName="${1}"

    checkNonEmptyString "${keyPairName}" 'undefined key pair name'

    aws ec2 describe-key-pairs \
        --key-name "${keyPairName}" \
        --no-cli-pager \
        --output 'text' \
        --query 'KeyPairs[0].[KeyFingerprint]' \
    2> '/dev/null' |
    grep -E -v '^None$'
}

function getLatestAMIIDByAMINamePattern()
{
    local -r amiIsPublic="${1}"
    local -r amiNamePattern="${2}"

    checkNonEmptyString "${amiIsPublic}" 'undefined ami is public'
    checkNonEmptyString "${amiNamePattern}" 'undefined ami name pattern'

    aws ec2 describe-images \
        --filters \
            'Name=architecture,Values=x86_64' \
            'Name=image-type,Values=machine' \
            "Name=is-public,Values=${amiIsPublic}" \
            "Name=name,Values=${amiNamePattern}" \
            'Name=state,Values=available' \
        --no-cli-pager \
        --output 'text' \
        --query 'sort_by(Images, &CreationDate)[-1].ImageId' |
    grep -E -v '^None$'
}

function getSecurityGroupIDByName()
{
    local -r securityGroupName="${1}"

    checkNonEmptyString "${securityGroupName}" 'undefined security group name'

    aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=${securityGroupName}" \
        --no-cli-pager \
        --output 'text' \
        --query 'SecurityGroups[0].[GroupId]' |
    grep -E -v '^None$'
}

function getSecurityGroupIDsByNames()
{
    local -r securityGroupNames=("${@}")

    local securityGroupIDs=''
    local securityGroupName=''

    for securityGroupName in "${securityGroupNames[@]}"
    do
        local securityGroupID=''
        securityGroupID="$(getSecurityGroupIDByName "${securityGroupName}")"

        checkNonEmptyString "${securityGroupID}" "security group name '${securityGroupName}' not found"

        securityGroupIDs="$(printf '%s\n%s' "${securityGroupIDs}" "${securityGroupID}")"
    done

    echo "${securityGroupIDs}"
}

function revokeSecurityGroupEgress()
{
    local -r securityGroupID="${1}"
    local -r securityGroupName="${2}"

    checkNonEmptyString "${securityGroupID}" 'undefined security group ID'
    checkNonEmptyString "${securityGroupName}" 'undefined security group name'

    local -r ipPermissionsEgress="$(
        aws ec2 describe-security-groups \
            --filters "Name=group-name,Values=${securityGroupName}" \
            --no-cli-pager \
            --output 'json' \
            --query 'SecurityGroups[0].[IpPermissionsEgress][0]'
    )"

    if [[ "$(isEmptyString "${ipPermissionsEgress}")" = 'false' && "${ipPermissionsEgress}" != '[]' ]]
    then
        aws ec2 revoke-security-group-egress \
            --group-id "${securityGroupID}" \
            --ip-permissions "${ipPermissionsEgress}" \
            --no-cli-pager
    fi
}

function revokeSecurityGroupIngress()
{
    local -r securityGroupID="${1}"
    local -r securityGroupName="${2}"

    checkNonEmptyString "${securityGroupID}" 'undefined security group ID'
    checkNonEmptyString "${securityGroupName}" 'undefined security group name'

    local -r ipPermissions="$(
        aws ec2 describe-security-groups \
            --filters "Name=group-name,Values=${securityGroupName}" \
            --no-cli-pager \
            --output 'json' \
            --query 'SecurityGroups[0].[IpPermissions][0]'
    )"

    if [[ "$(isEmptyString "${ipPermissions}")" = 'false' && "${ipPermissions}" != '[]' ]]
    then
        aws ec2 revoke-security-group-ingress \
            --group-id "${securityGroupID}" \
            --no-cli-pager \
            --ip-permissions "${ipPermissions}" \
            --no-cli-pager
    fi
}

function updateInstanceName()
{
    local -r instanceName="${1}"

    header 'UPDATING INSTANCE NAME'

    checkNonEmptyString "${instanceName}" 'undefined instance name'

    info "${instanceName}"

    aws ec2 create-tags \
        --no-cli-pager \
        --region "$(getInstanceRegion 'false')" \
        --resources "$(getInstanceID 'false')" \
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
    echo 'af-south-1 ap-east-1 ap-northeast-1 ap-northeast-2 ap-northeast-3 ap-south-1 ap-south-2 ap-southeast-1 ap-southeast-2 ap-southeast-3 ap-southeast-4 ap-southeast-5 ca-central-1 ca-west-1 cn-north-1 cn-northwest-1 eu-central-1 eu-central-2 eu-north-1 eu-south-1 eu-south-2 eu-west-1 eu-west-2 eu-west-3 il-central-1 me-central-1 me-south-1 sa-east-1 us-east-1 us-east-2 us-gov-east-1 us-gov-west-1 us-west-1 us-west-2'
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

function getShortRegionName()
{
    local -r region="${1}"

    checkValidRegion "${region}"

    if [[ "${region}" = 'af-south-1' ]]
    then
        echo 'afs1'
    elif [[ "${region}" = 'ap-east-1' ]]
    then
        echo 'ape1'
    elif [[ "${region}" = 'ap-northeast-1' ]]
    then
        echo 'apne1'
    elif [[ "${region}" = 'ap-northeast-2' ]]
    then
        echo 'apne2'
    elif [[ "${region}" = 'ap-northeast-3' ]]
    then
        echo 'apne3'
    elif [[ "${region}" = 'ap-south-1' ]]
    then
        echo 'aps1'
    elif [[ "${region}" = 'ap-south-2' ]]
    then
        echo 'aps2'
    elif [[ "${region}" = 'ap-southeast-1' ]]
    then
        echo 'apse1'
    elif [[ "${region}" = 'ap-southeast-2' ]]
    then
        echo 'apse2'
    elif [[ "${region}" = 'ap-southeast-3' ]]
    then
        echo 'apse3'
    elif [[ "${region}" = 'ap-southeast-4' ]]
    then
        echo 'apse4'
    elif [[ "${region}" = 'ap-southeast-5' ]]
    then
        echo 'apse5'
    elif [[ "${region}" = 'ca-central-1' ]]
    then
        echo 'cac1'
    elif [[ "${region}" = 'ca-west-1' ]]
    then
        echo 'caw1'
    elif [[ "${region}" = 'cn-north-1' ]]
    then
        echo 'cnn1'
    elif [[ "${region}" = 'cn-northwest-1' ]]
    then
        echo 'cnnw1'
    elif [[ "${region}" = 'eu-central-1' ]]
    then
        echo 'euc1'
    elif [[ "${region}" = 'eu-central-2' ]]
    then
        echo 'euc2'
    elif [[ "${region}" = 'eu-north-1' ]]
    then
        echo 'eun1'
    elif [[ "${region}" = 'eu-south-1' ]]
    then
        echo 'eus1'
    elif [[ "${region}" = 'eu-south-2' ]]
    then
        echo 'eus2'
    elif [[ "${region}" = 'eu-west-1' ]]
    then
        echo 'euw1'
    elif [[ "${region}" = 'eu-west-2' ]]
    then
        echo 'euw2'
    elif [[ "${region}" = 'eu-west-3' ]]
    then
        echo 'euw3'
    elif [[ "${region}" = 'il-central-1' ]]
    then
        echo 'ilc1'
    elif [[ "${region}" = 'me-central-1' ]]
    then
        echo 'mec1'
    elif [[ "${region}" = 'me-south-1' ]]
    then
        echo 'mes1'
    elif [[ "${region}" = 'sa-east-1' ]]
    then
        echo 'sae1'
    elif [[ "${region}" = 'us-east-1' ]]
    then
        echo 'use1'
    elif [[ "${region}" = 'us-east-2' ]]
    then
        echo 'use2'
    elif [[ "${region}" = 'us-gov-east-1' ]]
    then
        echo 'usgove1'
    elif [[ "${region}" = 'us-gov-west-1' ]]
    then
        echo 'usgovw1'
    elif [[ "${region}" = 'us-west-1' ]]
    then
        echo 'usw1'
    elif [[ "${region}" = 'us-west-2' ]]
    then
        echo 'usw2'
    fi
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

#################
# IAM UTILITIES #
#################

function cloneIAMRole()
{
    local -r existIAMRoleName="${1}"
    local -r newIAMRoleName="${2}"

    if [[ "$(existIAMRole "${existIAMRoleName}")" = 'false' ]]
    then
        fatal "\nFATAL : existing iam role '${existIAMRoleName}' not found"
    fi

    if [[ "$(existIAMRole "${newIAMRoleName}")" = 'true' ]]
    then
        fatal "\nFATAL : new iam role '${newIAMRoleName}' found"
    fi

    # Temp File Path

    local -r policyTempFilePath="$(getTemporaryFile)"

    # Get Exist IAM Role Trust Relationships

    aws iam get-role \
        --no-cli-pager \
        --output 'json' \
        --role-name "${existIAMRoleName}" |
    jq \
        --compact-output \
        --raw-output \
        '.["Role"] | .["AssumeRolePolicyDocument"] // empty' > "${policyTempFilePath}" ||
    rm -f "${policyTempFilePath}"

    # Create New IAM Role Using Exist IAM Role Trust Relationships

    local -r newIAMRole="$(
        aws iam create-role \
            --assume-role-policy-document "file://${policyTempFilePath}" \
            --no-cli-pager \
            --output 'json' \
            --role-name "${newIAMRoleName}"
    )"

    # Get Exist Inline Policies And Put Inline Policies

    local -r existInlinePolicyNames="$(
        aws iam list-role-policies \
            --no-cli-pager \
            --output 'json' \
            --role-name "${existIAMRoleName}" |
        jq \
            --compact-output \
            --raw-output \
            '.["PolicyNames"] | .[] // empty'
    )"

    local existInlinePolicyName=''

    for existInlinePolicyName in ${existInlinePolicyNames[@]}
    do
        local existInlineRolePolicy="$(
            aws iam get-role-policy \
                --no-cli-pager \
                --output 'json' \
                --policy-name "${existInlinePolicyName}" \
                --role-name "${existIAMRoleName}"
        )"

        jq --compact-output --raw-output '.["PolicyDocument"] // empty' <<< "${existInlineRolePolicy}" > "${policyTempFilePath}" ||
        rm -f "${policyTempFilePath}"

        aws iam put-role-policy \
            --no-cli-pager \
            --output 'json' \
            --policy-document "file://${policyTempFilePath}" \
            --policy-name "$(jq --compact-output --raw-output '.["PolicyName"] // empty' <<< "${existInlineRolePolicy}")" \
            --role-name "${newIAMRoleName}" ||
        rm -f "${policyTempFilePath}"
    done

    rm -f "${policyTempFilePath}"

    # Get Exist Managed Policies And Attach Managed Policies

    local -r managedPolicyArns="$(
        aws iam list-attached-role-policies \
            --no-cli-pager \
            --output 'json' \
            --role-name "${existIAMRoleName}" |
        jq \
            --compact-output \
            --raw-output \
            '.["AttachedPolicies"] | .[] | .["PolicyArn"] // empty' \
    )"

    local managedPolicyArn=''

    for managedPolicyArn in ${managedPolicyArns[@]}
    do
        aws iam attach-role-policy \
            --no-cli-pager \
            --policy-arn "${managedPolicyArn}" \
            --role-name "${newIAMRoleName}"
    done

    # Display New IAM Role

    jq --compact-output --raw-output --sort-keys '. // empty' <<< "${newIAMRole}"
}

function createIAMRole()
{
    local -r iamRoleName="${1}"

    if [[ "$(existIAMRole "${iamRoleName}")" = 'true' ]]
    then
        fatal "\nFATAL : iam role '${iamRoleName}' found"
    else
        header "CREATING IAM ROLE ${iamRoleName}"

        local -r policyTempFilePath="$(getTemporaryFile)"

        echo '{"Statement":[{"Action":"sts:AssumeRole","Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"}}],"Version":"2012-10-17"}' > "${policyTempFilePath}"

        aws iam create-role \
            --assume-role-policy-document "file://${policyTempFilePath}" \
            --no-cli-pager \
            --output 'json' \
            --role-name "${iamRoleName}" |
        jq --raw-output --sort-keys '. // empty' || rm -f "${policyTempFilePath}"

        rm -f "${policyTempFilePath}"
    fi
}

function deleteIAMRole()
{
    local -r iamRoleName="${1}"

    if [[ "$(existIAMRole "${iamRoleName}")" = 'true' ]]
    then
        header "DELETING IAM ROLE ${iamRoleName}"

        deleteIAMRoleInlinePolicies "${iamRoleName}"
        detachIAMRolePolicies "${iamRoleName}"
        removeIAMRoleFromInstanceProfile "${iamRoleName}"

        aws iam delete-role \
            --no-cli-pager \
            --output 'json' \
            --role-name "${iamRoleName}"

        echo -e "\n\033[1;32mdeleted iam role\033[0m '\033[1;34m${iamRoleName}\033[0m'"
    fi
}

function deleteIAMRoleInlinePolicies()
{
    local -r iamRoleName="${1}"

    local -r policies=($(
        aws iam list-role-policies \
            --no-cli-pager \
            --output 'json' \
            --role-name "${iamRoleName}" |
        jq \
            --compact-output \
            --raw-output \
            '.["PolicyNames"] | .[] // empty')
    )

    if [[ "${#policies[@]}" -gt '0' ]]
    then
        info 'deleting inline policies'

        local policy=''

        for policy in "${policies[@]}"
        do
            aws iam delete-role-policy \
                --no-cli-pager \
                --output 'json' \
                --role-name "${iamRoleName}" \
                --policy-name "${policy}"

            echo -e "  deleted '\033[1;35m${policy}\033[0m'"
        done
    fi
}

function detachIAMRolePolicies()
{
    local -r iamRoleName="${1}"

    local -r policyARNs=($(
        aws iam list-attached-role-policies \
            --no-cli-pager \
            --output 'json' \
            --role-name "${iamRoleName}" |
        jq \
            --compact-output \
            --raw-output \
            '.["AttachedPolicies"] | .[] | .["PolicyArn"] // empty')
    )

    if [[ "${#policyARNs[@]}" -gt '0' ]]
    then
        info '\ndetaching policies'

        local policyARN=''

        for policyARN in "${policyARNs[@]}"
        do
            aws iam detach-role-policy \
                --no-cli-pager \
                --output 'json' \
                --role-name "${iamRoleName}" \
                --policy-arn "${policyARN}"

            echo -e "  detached '\033[1;35m${policyARN}\033[0m'"
        done
    fi
}

function removeIAMRoleFromInstanceProfile()
{
    local -r iamRoleName="${1}"

    local -r instanceProfiles=($(
        aws iam list-instance-profiles-for-role \
            --no-cli-pager \
            --output 'json' \
            --role-name "${iamRoleName}" |
        jq \
            --compact-output \
            --raw-output \
            '.["InstanceProfiles"] | map(.["InstanceProfileName"])[]')
    )

    if [[ "${#instanceProfiles[@]}" -gt '0' ]]
    then
        info '\nremoving role from instance profiles'

        local instanceProfile=''

        for instanceProfile in "${instanceProfiles[@]}"
        do
            aws iam remove-role-from-instance-profile \
                --instance-profile-name "${instanceProfile}" \
                --no-cli-pager \
                --role-name "${iamRoleName}"

            echo -e "  removed role '\033[1;34m${iamRoleName}\033[0m' from instance profile '\033[1;35m${instanceProfile}\033[0m'"
        done
    fi
}

function existIAMRole()
{
    local -r iamRoleName="${1}"

    invertTrueFalseString "$(isEmptyString "$(aws iam get-role --no-cli-pager --role-name "${iamRoleName}" 2> '/dev/null')")"
}

###########################
# INSTANCE DATA UTILITIES #
###########################

function getInstanceAvailabilityZone()
{
    curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/placement/availability-zone'
}

function getInstanceIAMRole()
{
    curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/iam/info' |
    jq \
        --compact-output \
        --raw-output \
        --sort-keys \
        '.["InstanceProfileArn"] // empty' |
    cut -d '/' -f 2
}

function getInstanceID()
{
    local -r idOnly="${1}"

    local -r fullInstanceID="$(curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/instance-id')"

    if [[ "${idOnly}" = 'true' ]]
    then
        cut -d '-' -f 2 <<< "${fullInstanceID}"
    else
        echo "${fullInstanceID}"
    fi
}

function getInstanceMACAddress()
{
    curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/mac'
}

function getInstancePublicIPV4()
{
    curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/meta-data/public-ipv4'
}

function getInstanceRegion()
{
    local -r shortVersion="${1}"

    local -r availabilityZone="$(getInstanceAvailabilityZone)"

    checkNonEmptyString "${availabilityZone}" 'undefined availabilityZone'

    local -r fullRegionName="${availabilityZone:0:${#availabilityZone} - 1}"

    if [[ "${shortVersion}" = 'true' ]]
    then
        getShortRegionName "${fullRegionName}"
    else
        echo "${fullRegionName}"
    fi
}

function getInstanceSubnetID()
{
    curl -s --retry 12 --retry-delay 5 "http://instance-data/latest/meta-data/network/interfaces/macs/$(getInstanceMACAddress)/subnet-id"
}

function getInstanceUserDataValue()
{
    local -r key="$(escapeGrepSearchPattern "${1}")"

    trimString "$(
        curl -s --retry 12 --retry-delay 5 'http://instance-data/latest/user-data' |
        grep -E -o "^\s*${key}\s*=\s*.*$" |
        tail -1 |
        awk -F '=' '{ print $2 }'
    )"
}

function getInstanceVPCID()
{
    curl -s --retry 12 --retry-delay 5 "http://instance-data/latest/meta-data/network/interfaces/macs/$(getInstanceMACAddress)/vpc-id"
}

###########################
# LOAD BALANCER UTILITIES #
###########################

function getAWSELBAccountID()
{
    local -r region="${1}"

    checkValidRegion "${region}"

    if [[ "${region}" = 'af-south-1' ]]
    then
        echo '098369216593'
    elif [[ "${region}" = 'ap-east-1' ]]
    then
        echo '754344448648'
    elif [[ "${region}" = 'ap-northeast-1' ]]
    then
        echo '582318560864'
    elif [[ "${region}" = 'ap-northeast-2' ]]
    then
        echo '600734575887'
    elif [[ "${region}" = 'ap-northeast-3' ]]
    then
        echo '383597477331'
    elif [[ "${region}" = 'ap-south-1' ]]
    then
        echo '718504428378'
    elif [[ "${region}" = 'ap-southeast-1' ]]
    then
        echo '114774131450'
    elif [[ "${region}" = 'ap-southeast-2' ]]
    then
        echo '783225319266'
    elif [[ "${region}" = 'ap-southeast-3' ]]
    then
        echo '589379963580'
    elif [[ "${region}" = 'ca-central-1' ]]
    then
        echo '985666609251'
    elif [[ "${region}" = 'cn-north-1' ]]
    then
        echo '638102146993'
    elif [[ "${region}" = 'cn-northwest-1' ]]
    then
        echo '037604701340'
    elif [[ "${region}" = 'eu-central-1' ]]
    then
        echo '054676820928'
    elif [[ "${region}" = 'eu-north-1' ]]
    then
        echo '897822967062'
    elif [[ "${region}" = 'eu-south-1' ]]
    then
        echo '635631232127'
    elif [[ "${region}" = 'eu-west-1' ]]
    then
        echo '156460612806'
    elif [[ "${region}" = 'eu-west-2' ]]
    then
        echo '652711504416'
    elif [[ "${region}" = 'eu-west-3' ]]
    then
        echo '009996457667'
    elif [[ "${region}" = 'me-south-1' ]]
    then
        echo '076674570225'
    elif [[ "${region}" = 'sa-east-1' ]]
    then
        echo '507241528517'
    elif [[ "${region}" = 'us-east-1' ]]
    then
        echo '127311923021'
    elif [[ "${region}" = 'us-east-2' ]]
    then
        echo '033677994240'
    elif [[ "${region}" = 'us-gov-east-1' ]]
    then
        echo '190560391635'
    elif [[ "${region}" = 'us-gov-west-1' ]]
    then
        echo '048591011584'
    elif [[ "${region}" = 'us-west-1' ]]
    then
        echo '027434742980'
    elif [[ "${region}" = 'us-west-2' ]]
    then
        echo '797873946194'
    fi
}

function getLoadBalancerDNSNameByName()
{
    local -r loadBalancerName="${1}"

    checkNonEmptyString "${loadBalancerName}" 'undefined load balancer name'

    aws elb describe-load-balancers \
        --load-balancer-name "${loadBalancerName}" \
        --no-cli-pager \
        --output 'text' \
        --query 'LoadBalancerDescriptions[*].DNSName'
}

function isLoadBalancerFromStackName()
{
    local -r loadBalancerName="${1}"
    local -r stackName="${2}"

    checkNonEmptyString "${loadBalancerName}" 'undefined load balancer name'
    checkNonEmptyString "${stackName}" 'undefined stack name'

    local -r loadBalancerStackName="$(
        aws elb describe-tags \
            --load-balancer-name "${loadBalancerName}" \
            --no-cli-pager \
            --output 'json' |
        jq \
            --arg jqStackName "${stackName}" \
            --compact-output \
            --raw-output \
            --sort-keys \
            '.["TagDescriptions"] |
            .[] |
            .["Tags"] |
            .[] |
            select(.["Key"] == "aws:cloudformation:stack-name") |
            select(.["Value"] == $jqStackName) // empty'
    )"

    if [[ "$(isEmptyString "${loadBalancerStackName}")" = 'false' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function getLoadBalancerTag()
{
    local -r tags="${1}"
    local -r key="${2}"

    jq \
        --arg jqKey "${key}" \
        --compact-output \
        --raw-output \
        --sort-keys \
        '.["TagDescriptions"] |
        .[] |
        .["Tags"] |
        map(select(.["Key"] == $jqKey))[] |
        .["Value"] // empty' \
    <<< "${tags}"
}

function getLoadBalancerTags()
{
    local -r loadBalancerName="${1}"

    checkNonEmptyString "${loadBalancerName}" 'undefined load balancer name'

    aws elb describe-tags \
        --no-cli-pager \
        --output 'json' \
        --load-balancer-name "${loadBalancerName}"
}

######################
# ROUTE-53 UTILITIES #
######################

function getHostedZoneIDByDomainName()
{
    local -r hostedZoneDomainName="${1}"

    checkNonEmptyString "${hostedZoneDomainName}" 'undefined hosted zone domain name'

    aws route53 list-hosted-zones-by-name \
        --dns-name "${hostedZoneDomainName}" \
        --no-cli-pager \
        --output 'text' \
        --query 'HostedZones[0].[Id]' |
    grep -E -v '^None$' |
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

#################
# STS UTILITIES #
#################

function getAWSAccountID()
{
    aws sts get-caller-identity \
        --no-cli-pager \
        --output 'text' \
        --query 'Account'
}

#################
# VPC UTILITIES #
#################

function acceptVPCPeeringConnection()
{
    local -r vpcPeeringConnectionID="${1}"
    local -r vpcPeeringConnectionName="${2}"

    checkNonEmptyString "${vpcPeeringConnectionID}" 'undefined vpc peering connection id'

    if [[ "$(isEmptyString "${vpcPeeringConnectionName}")" = 'true' ]]
    then
        header "${vpcPeeringConnectionID}"
    else
        header "${vpcPeeringConnectionID} :: ${vpcPeeringConnectionName}"
    fi

    # Accept Connection Request

    local -r vpcPeeringConnection="$(
        aws ec2 accept-vpc-peering-connection \
            --no-cli-pager \
            --output 'json' \
            --vpc-peering-connection-id "${vpcPeeringConnectionID}" |
        jq \
            --compact-output \
            --raw-output \
            --sort-keys \
            '. // empty'
    )"

    # Update Connection Name

    if [[ "$(isEmptyString "${vpcPeeringConnectionName}")" = 'false' ]]
    then
        aws ec2 create-tags \
            --no-cli-pager \
            --resources "${vpcPeeringConnectionID}" \
            --tags "Key=Name,Value=${vpcPeeringConnectionName}"
    fi

    # Update Accepter Route Tables

    local -r requesterVPCCIDRBlocks="$(jq --compact-output --raw-output '.["VpcPeeringConnection"] | .["RequesterVpcInfo"] | .["CidrBlockSet"] | .[] | .["CidrBlock"] // empty' <<< "${vpcPeeringConnection}")"

    local -r accepterVPCID="$(jq --compact-output --raw-output '.["VpcPeeringConnection"] | .["AccepterVpcInfo"] | .["VpcId"] // empty' <<< "${vpcPeeringConnection}")"

    local -r accepterRouteTables="$(
        aws ec2 describe-route-tables \
            --filter "Name=vpc-id,Values=${accepterVPCID}" \
            --no-cli-pager \
            --output 'json'
    )"

    local -r accepterRouteTableIDs="$(jq --compact-output --raw-output '.["RouteTables"] | .[] | .["RouteTableId"] // empty' <<< "${accepterRouteTables}")"

    local accepterRouteTableID=''

    for accepterRouteTableID in ${accepterRouteTableIDs[@]}
    do
        local requesterVPCCIDRBlock=''

        for requesterVPCCIDRBlock in ${requesterVPCCIDRBlocks[@]}
        do
            echo -e "creating route with requester cidr \033[1;36m${requesterVPCCIDRBlock}\033[0m to route table \033[1;34m${accepterRouteTableID}\033[0m of \033[1;34m${accepterVPCID}\033[0m"

            local createRouteResult="$(
                aws ec2 create-route \
                    --destination-cidr-block "${requesterVPCCIDRBlock}" \
                    --no-cli-pager \
                    --output 'text' \
                    --route-table-id "${accepterRouteTableID}" \
                    --vpc-peering-connection-id "${vpcPeeringConnectionID}" 2>&1 |
                tr -d '\n'
            )"

            if [[ "${createRouteResult}" = 'True' ]]
            then
                echo -e "  \033[1;32mcreated route successfully\033[0m"
            else
                local existVPCPeeringConnectionID="$(
                    jq \
                        --arg jqAccepterRouteTableID "${accepterRouteTableID}" \
                        --arg jqRequesterVPCCIDRBlock "${requesterVPCCIDRBlock}" \
                        --compact-output \
                        --raw-output \
                        '.["RouteTables"] |
                         .[] |
                         select(.["RouteTableId"] == $jqAccepterRouteTableID) |
                         .["Routes"] |
                         .[] |
                         select(.["DestinationCidrBlock"] == $jqRequesterVPCCIDRBlock) |
                         .["VpcPeeringConnectionId"] // empty' \
                    <<< "${accepterRouteTables}"
                )"

                if [[ "${vpcPeeringConnectionID}" = "${existVPCPeeringConnectionID}" ]]
                then
                    warn "  WARN  : ${createRouteResult}"
                else
                    error "  ERROR : ${createRouteResult} (${existVPCPeeringConnectionID})"
                fi
            fi

            echo
        done
    done
}

function getAccepterVPCIDByVPCPeeringConnectionID()
{
    local -r vpcPeeringConnectionID="${1}"

    checkNonEmptyString "${vpcPeeringConnectionID}" 'undefined vpc peering connection id'

    aws ec2 describe-vpc-peering-connections \
        --filters "Name=vpc-peering-connection-id,Values=${vpcPeeringConnectionID}" \
        --no-cli-pager \
        --output 'json' |
    jq \
        --compact-output \
        --raw-output \
        '.["VpcPeeringConnections"] | .[] | .["AccepterVpcInfo"] | .["VpcId"] // empty'
}

function getAvailabilityZonesByVPCName()
{
    local -r vpcName="${1}"

    checkNonEmptyString "${vpcName}" 'undefined VPC name'

    local -r vpcID="$(getVPCIDByName "${vpcName}")"

    checkNonEmptyString "${vpcID}" 'undefined VPC ID'

    aws ec2 describe-subnets \
        --filters \
            'Name=state,Values=available' \
            "Name=vpc-id,Values=${vpcID}" \
        --no-cli-pager \
        --output 'json' \
        --query 'Subnets[*].AvailabilityZone' |
    jq \
        --compact-output \
        --raw-output \
        'unique |
        .[] // empty'
}

function getCurrentVPCCIDRBlock()
{
    curl -s --retry 12 --retry-delay 5 "http://instance-data/latest/meta-data/network/interfaces/macs/$(getInstanceMACAddress)/vpc-ipv4-cidr-block"
}

function getIPV4CIDRByVPCName()
{
    local -r vpcName="${1}"

    checkNonEmptyString "${vpcName}" 'undefined VPC name'

    aws ec2 describe-vpcs \
        --filter "Name=tag:Name,Values=${vpcName}" \
        --no-cli-pager \
        --output 'text' \
        --query 'Vpcs[0].CidrBlock' |
    grep -E -v '^None$'
}

function getPublicElasticIPs()
{
    aws ec2 describe-addresses \
        --no-cli-pager \
        --output 'text' \
        --query 'sort_by(Addresses, &PublicIp)[*].[PublicIp]'
}

function getRequesterCIDRByVPCPeeringConnectionID()
{
    local -r vpcPeeringConnectionID="${1}"

    checkNonEmptyString "${vpcPeeringConnectionID}" 'undefined vpc peering connection id'

    aws ec2 describe-vpc-peering-connections \
        --filters "Name=vpc-peering-connection-id,Values=${vpcPeeringConnectionID}" \
        --no-cli-pager \
        --output 'json' |
    jq \
        --compact-output \
        --raw-output \
        '.["VpcPeeringConnections"] | .[] | .["RequesterVpcInfo"] | .["CidrBlock"] // empty'
}

function getRequesterCIDRSetByVPCPeeringConnectionID()
{
    local -r vpcPeeringConnectionID="${1}"

    checkNonEmptyString "${vpcPeeringConnectionID}" 'undefined vpc peering connection id'

    aws ec2 describe-vpc-peering-connections \
        --filters "Name=vpc-peering-connection-id,Values=${vpcPeeringConnectionID}" \
        --no-cli-pager \
        --output 'json' |
    jq \
        --compact-output \
        --raw-output \
        '.["VpcPeeringConnections"] | .[] | .["RequesterVpcInfo"] | .["CidrBlockSet"] | .[] | .["CidrBlock"] // empty'
}

function getRequesterVPCIDByVPCPeeringConnectionID()
{
    local -r vpcPeeringConnectionID="${1}"

    checkNonEmptyString "${vpcPeeringConnectionID}" 'undefined vpc peering connection id'

    aws ec2 describe-vpc-peering-connections \
        --filters "Name=vpc-peering-connection-id,Values=${vpcPeeringConnectionID}" \
        --no-cli-pager \
        --output 'json' |
    jq \
        --compact-output \
        --raw-output \
        '.["VpcPeeringConnections"] | .[] | .["RequesterVpcInfo"] | .["VpcId"] // empty'
}

function getSubnetIDByName()
{
    local -r vpcName="${1}"
    local -r subnetName="${2}"

    local -r vpcID="$(getVPCIDByName "${vpcName}")"

    checkNonEmptyString "${vpcID}" 'undefined VPC ID'

    aws ec2 describe-subnets \
        --filter \
            "Name=tag:Name,Values=${subnetName}" \
            "Name=vpc-id,Values=${vpcID}" \
        --no-cli-pager \
        --output 'text' \
        --query 'Subnets[0].[SubnetId]' |
    grep -E -v '^None$'
}

function getSubnetIDsByNames()
{
    local -r vpcName="${1}"
    local -r subnetNames=("${@:2}")

    local subnetIDs=''
    local subnetName=''

    for subnetName in "${subnetNames[@]}"
    do
        local subnetID=''
        subnetID="$(getSubnetIDByName "${vpcName}" "${subnetName}")"

        checkNonEmptyString "${subnetID}" "subnet name '${subnetName}' not found"

        subnetIDs="$(printf '%s\n%s' "${subnetIDs}" "${subnetID}")"
    done

    echo "${subnetIDs}"
}

function getVPCIDByName()
{
    local -r vpcName="${1}"

    checkNonEmptyString "${vpcName}" 'undefined VPC name'

    aws ec2 describe-vpcs \
        --filter "Name=tag:Name,Values=${vpcName}" \
        --no-cli-pager \
        --output 'text' \
        --query 'Vpcs[0].[VpcId]' |
    grep -E -v '^None$'
}