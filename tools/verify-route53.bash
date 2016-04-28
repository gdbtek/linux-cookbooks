#!/bin/bash -e

function displayUsage()
{
    local -r scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e "\033[1;33m"
    echo    "SYNOPSIS :"
    echo    "    ${scriptName}"
    echo    "        --help"
    echo    "        --domain-name           <DOMAIN_NAME>"
    echo    "        --target-name-server    <TARGET_NAME_SERVER>"
    echo    "        --aws-profile           <AWS_PROFILE>"
    echo -e "\033[1;35m"
    echo    "DESCRIPTION :"
    echo    "    --help                  Help page"
    echo    "    --domain-name           Domain name"
    echo    "    --target-name-server    Target name server"
    echo    "    --aws-profile           AWS profile"
    echo -e "\033[1;36m"
    echo    "EXAMPLES :"
    echo    "    ./${scriptName} --help"
    echo    "    ./${scriptName} --domain-name 'typekit.net' --target-name-server 'ns1.p23.dynect.net'"
    echo    "    ./${scriptName} --domain-name 'typekit.net' --target-name-server 'ns1.p23.dynect.net' --profile 'typekit'"
    echo -e "\033[0m"

    exit "${1}"
}

function filterResultForComparation()
{
    local -r result="${1}"

    grep -i -v '^; <<>> DIG ' <<< "${result^^}" | grep -i -v ' found)$' | grep -E -i -v '(\s+SOA\s+|\s+NS\s+)' | sort
}

function getAWSNameServer()
{
    local -r domainName="${1}"
    local -r recordSetsJSON="${2}"
    local -r recordSetsLength="${3}"

    local i=0

    for ((i = 0; i < recordSetsLength; i = i + 1))
    do
        # shellcheck disable=SC2016,SC2155
        local recordSet="$(
            jq \
                --compact-output \
                --raw-output \
                --arg jqRecordSetIndex "${i}" \
                '.["ResourceRecordSets"] | .[$jqRecordSetIndex | tonumber] // empty' \
                <<< "${recordSetsJSON}"
        )"

        # shellcheck disable=SC2155
        local recordSetName="$(
            jq \
                --compact-output \
                --raw-output \
                '.["Name"] // empty' \
                <<< "${recordSet}"
        )"

        # shellcheck disable=SC2155
        local recordSetType="$(
            jq \
                --compact-output \
                --raw-output \
                '.["Type"] // empty' \
                <<< "${recordSet}"
        )"

        if [[ "${recordSetName}" = "${domainName}." && "${recordSetType}" = 'NS' ]]
        then
            jq \
                --compact-output \
                --raw-output \
                '.["ResourceRecords"] | .[0][] // empty' \
                <<< "${recordSet}"
        fi
    done
}

function verify()
{
    local -r domainName="${1}"
    local -r targetNameServer="${2}"
    local -r awsProfile="${3}"

    # Get Hosted Zone ID

    local -r hostedZoneID="$(getHostedZoneIDByDomainName "${domainName}")"

    checkNonEmptyString "${hostedZoneID}" 'undefined hosted zone ID'

    # Set Default Profile

    if [[ "$(isEmptyString "${awsProfile}")" = 'false' ]]
    then
        export AWS_DEFAULT_PROFILE="${awsProfile}"
    fi

    # Get Record Sets JSON

    local -r recordSetsJSON="$(aws route53 list-resource-record-sets --hosted-zone-id "${hostedZoneID}")"

    # Record Sets

    local -r recordSetsLength="$(
        jq \
            --compact-output \
            --raw-output \
            '.["ResourceRecordSets"] | length // empty' \
            <<< "${recordSetsJSON}"
    )"

    # Find One AWS Name Server

    local -r awsNameServer="$(getAWSNameServer "${domainName}" "${recordSetsJSON}" "${recordSetsLength}")"

    checkNonEmptyString "${awsNameServer}" 'undefined AWS name server'

    # Dig Each Record Set

    local i=0

    for ((i = 0; i < recordSetsLength; i = i + 1))
    do
        info "verifying record set $((i + 1)) of ${recordSetsLength}"

        # shellcheck disable=SC2016,SC2155
        local recordSet="$(
            jq \
                --compact-output \
                --raw-output \
                --arg jqRecordSetIndex "${i}" \
                '.["ResourceRecordSets"] | .[$jqRecordSetIndex | tonumber] // empty' \
                <<< "${recordSetsJSON}"
        )"

        # shellcheck disable=SC2155
        local recordSetName="$(
            jq \
                --compact-output \
                --raw-output \
                '.["Name"] // empty' \
                <<< "${recordSet}"
        )"

        # shellcheck disable=SC2155
        local recordSetType="$(
            jq \
                --compact-output \
                --raw-output \
                '.["Type"] // empty' \
                <<< "${recordSet}"
        )"

        echo -e "    name : \033[1;35m${recordSetName}\033[0m"
        echo -e "    type : \033[1;35m${recordSetType}\033[0m"

        # Skip Type NS and SOA

        if [[ "${recordSetName}" = "${domainName}." && ("${recordSetType}" = 'NS' || "${recordSetType}" = 'SOA') ]]
        then
            echo -e "    \033[1;33mskipped default record set\033[0m"
        else
            echo '    digging record set :'

            # Dig AWS Name Server

            debug "        dig @${awsNameServer} '${recordSetName}' ANY +noall +answer"
            # shellcheck disable=SC2016,SC2155
            local awsDigResult="$(dig @${awsNameServer} "${recordSetName}" ANY +noall +answer 2>&1 || true)"
            sed 's/^/            /' <<< "${awsDigResult}"
            echo

            # Dig Target Name Server

            debug "        dig @${targetNameServer} '${recordSetName}' ANY +noall +answer"
            # shellcheck disable=SC2016,SC2155
            local targetDigResult="$(dig @${targetNameServer} "${recordSetName}" ANY +noall +answer 2>&1 || true)"
            sed 's/^/            /' <<< "${targetDigResult}"
            echo

            # Compare AWS Result and Target Result

            # shellcheck disable=SC2155
            local diffResult="$(
                diff <(filterResultForComparation "${awsDigResult}") \
                     <(filterResultForComparation "${targetDigResult}")
            )"

            if [[ "$(isEmptyString "${diffResult}")" = 'true' ]]
            then
                echo -e "    \033[1;32mdig results are same\033[0m"
            else
                echo -e "    \033[1;31mdig results are different :\033[0m"
                echo -e "    \033[1;31m$(sed 's/^/        /' <<< "${diffResult}")\033[0m"
            fi
        fi

        echo
    done
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local -r optCount="${#}"

    source "${appFolderPath}/../libraries/aws.bash"
    source "${appFolderPath}/../libraries/util.bash"

    while [[ "${#}" -gt '0' ]]
    do
        case "${1}" in
            --help)
                displayUsage 0
                ;;

            --domain-name)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local -r domainName="${1}"
                fi

                ;;

            --target-name-server)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local -r targetNameServer="${1}"
                fi

                ;;

            --aws-profile)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local -r awsProfile="${1}"
                fi

                ;;

            *)
                shift
                ;;
        esac
    done

    # Validate Opt

    if [[ "${optCount}" -lt '1' ]]
    then
        displayUsage 0
    fi

    # Validate Inputs

    if [[ "$(isEmptyString "${domainName}")" = 'true' ]]
    then
        error '\nERROR : domain name not found'
        displayUsage 1
    fi

    if [[ "$(isEmptyString "${targetNameServer}")" = 'true' ]]
    then
        error '\nERROR : target name server not found'
        displayUsage 1
    fi

    # Verify

    verify "${domainName}" "${targetNameServer}" "${awsProfile}"
}

main "${@}"