#!/bin/bash -e

##################
# IMPLEMENTATION #
##################

function displayUsage()
{
    local -r scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e '\033[1;33m'
    echo    'SYNOPSIS :'
    echo    "  ${scriptName}"
    echo    '    --help'
    echo    '    --port    <PORT>'
    echo -e '\033[1;35m'
    echo    'DESCRIPTION :'
    echo    '  --help    Help page (optional)'
    echo    '  --port    Port number of server (require)'
    echo -e '\033[1;36m'
    echo    'EXAMPLES :'
    echo    "  ./${scriptName} --help"
    echo    "  ./${scriptName} --port '8080'"
    echo -e '\033[0m'

    exit "${1}"
}

function startHTTPServer()
{
    local -r port="${1}"

    python -m 'SimpleHTTPServer' "${port}"
}

########
# MAIN #
########

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    # Parsing Command Arguments

    local -r optCount="${#}"

    while [[ "${#}" -gt '0' ]]
    do
        case "${1}" in
            --help)
                displayUsage 0
                ;;

            --port)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local port="${1}"
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

    # Validate Port

    checkNaturalNumber "${port}"

    # Start Cleaning

    startHTTPServer "${port}"
}

main "${@}"