#!/bin/bash -e

#############
# CONSTANTS #
#############

NUMBER_BUILDS_TO_KEEP='15'

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
    echo    '    --jobs-folder-path         <JOBS_FOLDER_PATH>'
    echo    '    --number-builds-to-keep    <NUMBER_BUILD_TO_KEEP>'
    echo -e '\033[1;35m'
    echo    'DESCRIPTION :'
    echo    '  --help                     Help page (optional)'
    echo    '  --jobs-folder-path         Path to Jenkins jobs folder path (require)'
    echo    '                             Examples: /opt/jenkins/jobs, /apps/jenkins/latest/jobs'
    echo    '  --number-builds-to-keep    Max # of builds to keep with artifacts (optional)'
    echo    "                             Default to ${NUMBER_BUILDS_TO_KEEP}"
    echo -e '\033[1;36m'
    echo    'EXAMPLES :'
    echo    "  ./${scriptName} --help"
    echo    "  ./${scriptName} --jobs-folder-path '/opt/jenkins/jobs'"
    echo    "  ./${scriptName} --jobs-folder-path '/apps/jenkins/latest/jobs' --number-builds-to-keep '10'"
    echo -e '\033[0m'

    exit "${1}"
}

function cleanJenkinsJobs()
{
    local -r jobsFolderPath="${1}"
    local -r numberBuildsToKeep="${2}"

    find "${jobsFolderPath}" -mindepth 1 -maxdepth 4 -type d -name 'builds'
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

            --jobs-folder-path)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local jobsFolderPath="${1}"
                fi

                ;;

            --number-builds-to-keep)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local numberBuildsToKeep="${1}"
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

    # Default Values

    if [[ "$(isEmptyString "${numberBuildsToKeep}")" = 'true' ]]
    then
        numberBuildsToKeep="${NUMBER_BUILDS_TO_KEEP}"
    fi

    # Validation

    checkExistFolder "${jobsFolderPath}"
    checkNaturalNumber "${numberBuildsToKeep}"

    # Start Cleaning

    cleanJenkinsJobs "${jobsFolderPath}" "${numberBuildsToKeep}"
}

main "${@}"