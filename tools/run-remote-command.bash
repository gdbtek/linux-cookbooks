#!/bin/bash -e

#############
# CONSTANTS #
#############

SSH_CONNECTION_ATTEMPTS='3'
SSH_CONNECTION_TIMEOUT_IN_SECONDS='5'

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
    echo    '    --identity-file    <IDENTITY_FILE>'
    echo    '    --login-name       <LOGIN_NAME>'
    echo    '    --command          <COMMAND>'
    echo    '    --address          <ADDRESS>'
    echo -e '\033[1;35m'
    echo    'DESCRIPTION :'
    echo    '  --help             Help page (optional)'
    echo    '  --identity-file    Path to identity file (optional)'
    echo    '  --login-name       Login name (optional)'
    echo    '  --command          Command that will be run in remote servers (require)'
    echo    '  --address          List of server address seperated by spaces or commas (require)'
    echo -e '\033[1;36m'
    echo    'EXAMPLES :'
    echo    "  ./${scriptName} --help"
    echo    "  ./${scriptName} --command 'date' --address '1.2.3.4, 5.6.7.8'"
    echo    "  ./${scriptName} --identity-file '/path/to/key.pem' --login-name 'ec2-user' --command 'ntpstat' --address '1.2.3.4, 5.6.7.8'"
    echo    "  ./${scriptName} --identity-file '/path/to/key.pem' --login-name 'ec2-user' --command 'chronyc tracking' --address '1.2.3.4, 5.6.7.8'"
    echo -e '\033[0m'

    exit "${1}"
}

function runCommand()
{
    local -r identityFile="${1}"
    local -r loginName="${2}"
    local -r command="${3}"
    local -r addresses=($(sortUniqArray "${@:4}"))

    # Built Prompt

    local -r prompt='echo -e "\033[1;36m<\033[31m$(whoami)\033[34m@\033[33m$(hostname)\033[36m><\033[35m$(pwd)\033[36m>\033[0m"'

    # Get Identity File Option

    local identityOption=()

    if [[ "$(isEmptyString "${identityFile}")" = 'false' && -f "${identityFile}" ]]
    then
        identityOption=('-i' "${identityFile}")
    fi

    # Address Walker

    local address=''

    for address in "${addresses[@]}"
    do
        if [[ "$(isEmptyString "${address}")" = 'false' ]]
        then
            header "${address}"

            if [[ "$(isEmptyString "${loginName}")" = 'true' ]]
            then
                ssh "${identityOption[@]}" \
                    -o 'IdentitiesOnly yes' \
                    -o "ConnectionAttempts ${SSH_CONNECTION_ATTEMPTS}" \
                    -o "ConnectTimeout ${SSH_CONNECTION_TIMEOUT_IN_SECONDS}" \
                    -n "${address}" "${prompt} && ${command}" || true
            else
                ssh "${identityOption[@]}" \
                    -o 'IdentitiesOnly yes' \
                    -o "ConnectionAttempts ${SSH_CONNECTION_ATTEMPTS}" \
                    -o "ConnectTimeout ${SSH_CONNECTION_TIMEOUT_IN_SECONDS}" \
                    -n "${loginName}@${address}" "${prompt} && ${command}" || true
            fi
        fi
    done
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

            --identity-file)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local identityFile="$(formatPath ${1})"
                fi

                ;;

            --login-name)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local loginName="${1}"
                fi

                ;;

            --command)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local command="$(trimString "${1}")"
                fi

                ;;

            --address)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local address="$(replaceString "${1}" ',' ' ')"
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

    # Validate Arguments

    checkNonEmptyString "${command}" 'undefined command'
    checkNonEmptyString "${address}" 'undefined address'

    # Start Run Remote Command

    runCommand "${identityFile}" "${loginName}" "${command}" "${address}"
}

main "${@}"