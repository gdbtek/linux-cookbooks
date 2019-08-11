#!/bin/bash -e

#############
# CONSTANTS #
#############

DEFAULT_COMMAND_MODE='status'
DEFAULT_NUMBER_BUILDS_TO_KEEP='15'

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
    echo    '    --command-mode             <COMMAND_MODE>'
    echo -e '\033[1;35m'
    echo    'DESCRIPTION :'
    echo    '  --help                     Help page (optional)'
    echo    '  --jobs-folder-path         Path to Jenkins jobs folder path (require)'
    echo    '                             Examples: /opt/jenkins/jobs, /apps/jenkins/latest/jobs'
    echo    '  --number-builds-to-keep    Max # of builds to keep with artifacts (optional)'
    echo    "                             Default to ${DEFAULT_NUMBER_BUILDS_TO_KEEP}"
    echo    "  --command-mode             Valid command mode : 'clean-up', or '${DEFAULT_COMMAND_MODE}' (optional)"
    echo    "                             Default value is '${DEFAULT_COMMAND_MODE}'"
    echo -e '\033[1;36m'
    echo    'EXAMPLES :'
    echo    "  ./${scriptName} --help"
    echo    "  ./${scriptName} --jobs-folder-path '/opt/jenkins/jobs'"
    echo    "  ./${scriptName} --jobs-folder-path '/apps/jenkins/latest/jobs' --number-builds-to-keep '15'"
    echo    "  ./${scriptName} --jobs-folder-path '/apps/jenkins/latest/jobs' --number-builds-to-keep '15' --command-mode 'clean-up'"
    echo -e '\033[0m'

    exit "${1}"
}

function cleanUpDotBuildFolder()
{
    local -r buildsFolderPath="${1}"
    local -r commandMode="${2}"

    # Dot Builds (builds/.12345)

    local dotBuilds="$(
        find \
            "${buildsFolderPath}" \
            -mindepth 1 -maxdepth 1 \
            \( -type d -o -type l \) \
            -regex "^${buildsFolderPath}/\.[1-9][0-9]*$" \
            -exec basename '{}' \;
    )"

    if [[ "$(isEmptyString "${dotBuilds}")" = 'false' ]]
    then
        NEED_TO_CLEAN_UP_DOT_BUILDS='true'

        info "\n${buildsFolderPath}"

        if [[ "${commandMode}" = 'clean-up' ]]
        then
            echo -e "  \033[1;35mdeleting dot-builds :\033[0m"
        else
            echo -e "  \033[1;35mto delete dot-builds :\033[0m"
        fi

        local dotBuild=''

        for dotBuild in ${dotBuilds}
        do
            echo "    '${buildsFolderPath}/${dotBuild}'"

            if [[ "${commandMode}" = 'clean-up' ]]
            then
                rm -f -r "${buildsFolderPath}/${dotBuild}"
            fi
        done
    fi
}

function cleanUpBuildFolder()
{
    local -r buildsFolderPath="${1}"
    local -r commandMode="${2}"
    local -r numberBuildsToKeep="${3}"

    # Normal Builds (builds/12345)

    local builds="$(
        find \
            "${buildsFolderPath}" \
            -mindepth 1 -maxdepth 1 \
            -type d \
            -regex "^${buildsFolderPath}/[1-9][0-9]*$" \
            -exec basename '{}' \; |
        sort -n -r
    )"

    local toDeleteBuilds="$(tail -n "+$((numberBuildsToKeep + 1))" <<< "${builds}")"
    local toKeepBuilds="$(head "-${numberBuildsToKeep}" <<< "${builds}")"

    if [[ "$(isEmptyString "${toDeleteBuilds}")" = 'false' ]]
    then
        NEED_TO_CLEAN_UP_BUILDS='true'

        info "\n${buildsFolderPath}"

        # Print To Keep If Available

        if [[ "$(isEmptyString "${toKeepBuilds}")" = 'false' ]]
        then
            echo -e "  \033[1;32mto keep builds :\033[0m"

            local toKeepBuild=''

            for toKeepBuild in ${toKeepBuilds}
            do
                checkPositiveInteger "${toKeepBuild}"

                echo "    '${buildsFolderPath}/${toKeepBuild}'"
            done
        fi

        # Print To Delete As Always

        if [[ "${commandMode}" = 'clean-up' ]]
        then
            echo -e "  \033[1;35mdeleting builds :\033[0m"
        else
            echo -e "  \033[1;35mto delete builds :\033[0m"
        fi

        # Delete

        local toDeleteBuild=''

        for toDeleteBuild in ${toDeleteBuilds}
        do
            checkPositiveInteger "${toDeleteBuild}"

            echo "    '${buildsFolderPath}/${toDeleteBuild}'"

            if [[ "${commandMode}" = 'clean-up' ]]
            then
                rm -f -r "${buildsFolderPath}/${toDeleteBuild}"
            fi
        done
    fi
}

function cleanJenkinsJobs()
{
    local -r jobsFolderPath="${1}"
    local -r numberBuildsToKeep="${2}"
    local -r commandMode="${3}"

    local -r oldIFS="${IFS}"
    IFS=$'\n'

    NEED_TO_CLEAN_UP_DOT_BUILDS='false'
    NEED_TO_CLEAN_UP_BUILDS='false'

    local buildsFolderPath=''

    for buildsFolderPath in $(find "${jobsFolderPath}" -mindepth 1 -maxdepth 4 -type d -name 'builds')
    do
        cleanUpDotBuildFolder "${buildsFolderPath}" "${commandMode}"
        cleanUpBuildFolder "${buildsFolderPath}" "${commandMode}" "${numberBuildsToKeep}"
    done

    IFS="${oldIFS}"

    if [[ "${NEED_TO_CLEAN_UP_DOT_BUILDS}" = 'false' ]]
    then
        echo -e "\n\033[1;32mno dot-build to clean up!\033[0m"
    fi

    if [[ "${NEED_TO_CLEAN_UP_BUILDS}" = 'false' ]]
    then
        echo -e "\n\033[1;32mno build to clean up!\033[0m"
    fi
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

            --command-mode)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local commandMode="$(trimString "${1}")"
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
        numberBuildsToKeep="${DEFAULT_NUMBER_BUILDS_TO_KEEP}"
    fi

    if [[ "$(isEmptyString "${commandMode}")" = 'true' ]]
    then
        commandMode="${DEFAULT_COMMAND_MODE}"
    fi

    # Validation

    checkExistFolder "${jobsFolderPath}"
    checkNaturalNumber "${numberBuildsToKeep}" 'number builds to keep is not natural number'

    if [[ ! -f "${jobsFolderPath}/../config.xml" || ! -d "${jobsFolderPath}/../plugins" ]]
    then
        fatal "\n'${jobsFolderPath}' is not jenkins jobs folder"
    fi

    if [[ "${commandMode}" != 'clean-up' && "${commandMode}" != 'status' ]]
    then
        error '\nERROR : command mode must be clean-up, or status'
        displayUsage 1
    fi

    # Start Cleaning

    cleanJenkinsJobs "${jobsFolderPath}" "${numberBuildsToKeep}" "${commandMode}"
    postUpMessage
}

main "${@}"