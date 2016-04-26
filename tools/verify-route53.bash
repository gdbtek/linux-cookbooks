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

    local -r hostedZoneID="$(getHostedZoneIDByDomainName "${domainName}")"

    checkNonEmptyString "${hostedZoneID}" 'undefined hosted zone ID'

    aws route53 list-resource-record-sets --hosted-zone-id "${hostedZoneID}"
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