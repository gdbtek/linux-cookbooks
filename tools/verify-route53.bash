#!/bin/bash -e

function displayUsage()
{
    local -r scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e "\033[1;33m"
    echo    "SYNOPSIS :"
    echo    "    ${scriptName}"
    echo    "        --help"
    echo    "        --zone-name        <ZONE_NAME>"
    echo    "        --name-server-a    <NAME_SERVER_A>"
    echo    "        --name-server-b    <NAME_SERVER_B>"
    echo -e "\033[1;35m"
    echo    "DESCRIPTION :"
    echo    "    --help             Help page"
    echo    "    --zone-name        Zone name"
    echo    "    --name-server-a    Name server A"
    echo    "    --name-server-b    Name server B"
    echo -e "\033[1;36m"
    echo    "EXAMPLES :"
    echo    "    ./${scriptName} --help"
    echo    "    ./${scriptName} --zone-name 'typekit.com' --name-server-a 'ns-964.awsdns-56.net' --name-server-b 'ns1.p23.dynect.net'"
    echo -e "\033[0m"

    exit "${1}"
}

function verify()
{
    local -r zoneName="${1}"
    local -r nameServerA="${2}"
    local -r nameServerB="${3}"

    # Populate Machine List


}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local -r optCount="${#}"

    source "${appFolderPath}/../libraries/util.bash"

    while [[ "${#}" -gt '0' ]]
    do
        case "${1}" in
            --help)
                displayUsage 0
                ;;

            --zone-name)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local -r zoneName="${1}"
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

    verify "${zoneName}" "${nameServerA}" "${nameServerB}"
}

main "${@}"