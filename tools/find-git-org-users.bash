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
    echo    '    --user          <USER>'
    echo    '    --token         <TOKEN>'
    echo    '    --org-names     <ORGANIZATION_NAMES>'
    echo    '    --find-users    <USER_LIST>'
    echo    '    --git-url       <GIT_URL>'
    echo -e '\033[1;35m'
    echo    'DESCRIPTION :'
    echo    '  --help          Help page (optional)'
    echo    '  --user          User name (require)'
    echo    '  --token         Personal access token (require)'
    echo    '  --org-names     List of organization names seperated by spaces or commas (require)'
    echo    '  --find-users    List of users to find on organizations seperated by spaces or commas (require)'
    echo    '  --git-url       Git URL (optional)'
    echo    "                  Default to 'https://api.github.com'"
    echo -e '\033[1;36m'
    echo    'EXAMPLES :'
    echo    "  ./${scriptName} --help"
    echo    "  ./${scriptName} --user 'nnguyen' --token 'a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9' --org-names 'my-org-1, my-org-2' --find-users 'nnguyen, nam'"
    echo    "  ./${scriptName} --user 'nnguyen' --token 'a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9' --org-names 'my-org-1, my-org-2' --find-users 'nnguyen, nam' --git-url 'https://my.git.com/api/v3'"

    echo -e '\033[0m'

    exit "${1}"
}

function findGitOrgTeamUsers()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local -r gitURL="${4}"
    local -r findUsers=($(sortUniqArray "${@:5}"))

    # Validation

    checkNonEmptyString "${user}" 'undefined user'
    checkNonEmptyString "${token}" 'undefined token'
    checkNonEmptyString "${orgName}" 'undefined organization name'

    # Team Walker

    local -r teams="$(getGitOrgTeams "${user}" "${token}" "${orgName}" "${gitURL}")"
    local -r teamsLength="$(jq '. | length' <<< "${teams}")"
    local i=0

    for ((i = 0; i < teamsLength; i = i + 1))
    do
        local team=''
        team="$(
            jq \
                --compact-output \
                --raw-output \
                --arg jqIndex "${i}" \
                '.[$jqIndex | tonumber] // empty' \
            <<< "${teams}"
        )"

        local htmlURL=''
        htmlURL="$(
            jq \
                --compact-output \
                --raw-output \
                '.["html_url"] // empty' \
            <<< "${team}"
        )"

        local membersURL=''
        membersURL="$(
            jq \
                --compact-output \
                --raw-output \
                '.["members_url"] // empty' \
            <<< "${team}" |
            cut -d '{' -f 1
        )"

        local teamUsers=''
        teamUsers="$(getGitTeamUsers "${user}" "${token}" "${gitURL}" "${membersURL}")"

        # Find Users Walker

        local findUser=''

        for findUser in "${findUsers[@]}"
        do
            findUser="$(tr '[:upper:]' '[:lower:]' <<< "${findUser}")"

            local foundUser=''
            foundUser="$(
                jq \
                    --compact-output \
                    --raw-output \
                    --arg jqLogin "${findUser}" \
                    '.[] | select(.["login"] == $jqLogin) // empty' \
                <<< "${teamUsers}"
            )"

            if [[ "$(isEmptyString "${foundUser}")" = 'false' ]]
            then
                echo -e "found user \033[1;36m${findUser}\033[0m in team \033[1;32m${htmlURL}\033[0m"
            fi
        done
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

            --user)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local user="${1}"
                fi

                ;;

            --token)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local token="${1}"
                fi

                ;;

            --org-names)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local orgNames=''
                    orgNames=($(sortUniqArray "$(replaceString "${1}" ',' ' ')"))
                fi

                ;;

            --find-users)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local findUsers=''
                    findUsers="$(replaceString "${1}" ',' ' ')"
                fi

                ;;

            --git-url)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local gitURL="${1}"
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

    # Validation

    checkNonEmptyString "${user}" 'undefined user'
    checkNonEmptyString "${token}" 'undefined token'
    checkNonEmptyString "${orgNames}" 'undefined organization names'
    checkNonEmptyString "${findUsers}" 'undefined find users'

    # Organization Walker

    local orgName=''

    for orgName in "${orgNames[@]}"
    do
        orgName="$(tr '[:lower:]' '[:upper:]' <<< "${orgName}")"

        header "FINDING TEAM USERS IN GIT ORG ${orgName}"
        findGitOrgTeamUsers "${user}" "${token}" "${orgName}" "${gitURL}" "${findUsers}"
    done
}

main "${@}"