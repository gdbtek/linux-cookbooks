#!/bin/bash -e

function displayUsage()
{
    local -r scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e "\033[1;33m"
    echo    "SYNOPSIS :"
    echo    "    ${scriptName}"
    echo    "        --help"
    echo    "        --domain-name      <DOMAIN_NAME>"
    echo    "        --name-server-a    <NAME_SERVER_A>"
    echo    "        --name-server-b    <NAME_SERVER_B>"
    echo -e "\033[1;35m"
    echo    "DESCRIPTION :"
    echo    "    --help             Help page"
    echo    "    --domain-name      Domain name"
    echo    "    --name-server-a    Name server A"
    echo    "    --name-server-b    Name server B"
    echo -e "\033[1;36m"
    echo    "EXAMPLES :"
    echo    "    ./${scriptName} --help"
    echo    "    ./${scriptName} --domain-name 'typekit.net' --name-server-a 'ns-964.awsdns-56.net' --name-server-b 'ns1.p23.dynect.net'"
    echo -e "\033[0m"

    exit "${1}"
}

function verify()
{
    local -r domainName="${1}"
    local -r nameServerA="${2}"
    local -r nameServerB="${3}"

    # Get Hosted Zone ID

    local -r hostedZoneID="$(getHostedZoneIDByDomainName "${domainName}")"

    checkNonEmptyString "${hostedZoneID}" 'undefined hosted zone ID'

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

    local i=0

    for ((i = 0; i < recordSetsLength; i = i + 1))
    do
        info "verifying record set $((i + 1)) of ${recordSetsLength}"

        local recordSet="$(
            jq \
                --compact-output \
                --raw-output \
                --arg jqRecordSetIndex "${i}" \
                '.["ResourceRecordSets"] | .[$jqRecordSetIndex | tonumber] // empty' \
                <<< "${recordSetsJSON}"
        )"

        local recordSetName="$(
            jq \
                --compact-output \
                --raw-output \
                '.["Name"] // empty' \
                <<< "${recordSet}"
        )"

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
            echo -e "        \033[1;33mskipped default record set\033[0m"
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

            --name-server-a)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local -r nameServerA="${1}"
                fi

                ;;

            --name-server-b)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local -r nameServerB="${1}"
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

    # Verify

    verify "${domainName}" "${nameServerA}" "${nameServerB}"
}

main "${@}"
