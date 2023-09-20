#!/bin/bash -e

#############
# CONSTANTS #
#############

DEFAULT_IS_ACTION_MODE='false'

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
    echo    '    --user                      <USER>'
    echo    '    --token                     <TOKEN>'
    echo    '    --org-names                 <ORGANIZATION_NAMES>'
    echo    '    --find-users                <USER_LIST>'
    echo    '    --git-url                   <GIT_URL>'
    echo    '    --remove-find-users         <REMOVE_FIND_USERS>'
    echo    '    --remove-suspended-users    <REMOVE_SUSPENDED_USERS>'
    echo -e '\033[1;35m'
    echo    'DESCRIPTION :'
    echo    '  --help                      Help page (optional)'
    echo    '  --user                      User name (require)'
    echo    '  --token                     Personal access token (require)'
    echo    '  --org-names                 List of organization names seperated by spaces or commas (require)'
    echo    '  --find-users                List of users to find on organizations seperated by spaces or commas (require)'
    echo    '  --git-url                   Git URL (optional)'
    echo    "                              Default to 'https://api.github.com'"
    echo    "  --remove-find-users         Valid value : 'true', or '${DEFAULT_IS_ACTION_MODE}' (optional)"
    echo    "                              Default value is '${DEFAULT_IS_ACTION_MODE}'"
    echo    "  --remove-suspended-users    Valid value : 'true', or '${DEFAULT_IS_ACTION_MODE}' (optional)"
    echo    "                              Default value is '${DEFAULT_IS_ACTION_MODE}'"
    echo -e '\033[1;36m'
    echo    'EXAMPLES :'
    echo    "  ./${scriptName} --help"
    echo    "  ./${scriptName} --user 'nnguyen' --token 'a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9' --org-names 'my-org-1, my-org-2' --find-users 'nnguyen, nam'"
    echo    "  ./${scriptName} --user 'nnguyen' --token 'a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9' --org-names 'my-org-1, my-org-2' --find-users 'nnguyen, nam' --remove-suspended-users 'true'"
    echo    "  ./${scriptName} --user 'nnguyen' --token 'a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9' --org-names 'my-org-1, my-org-2' --find-users 'nnguyen, nam' --git-url 'https://my.git.com/api/v3'"

    echo -e '\033[0m'

    exit "${1}"
}

function findRemoveGitOrgTeamUsers()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local -r gitURL="${4}"
    local -r isRemoveFindUsers="${5}"
    local -r isRemoveSuspendedUsers="${6}"
    local -r findUsers=($(sortUniqArray "${@:7}"))

    # Validation

    checkNonEmptyString "${user}" 'undefined user'
    checkNonEmptyString "${token}" 'undefined token'
    checkNonEmptyString "${orgName}" 'undefined organization name'

    # Team Walker

    local -r teams="$(getGitOrganizationTeams "${user}" "${token}" "${orgName}" "${gitURL}")"
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

        local teamHTMLURL=''
        teamHTMLURL="$(
            jq \
                --compact-output \
                --raw-output \
                '.["html_url"] // empty' \
            <<< "${team}"
        )"

        local teamURL=''
        teamURL="$(
            jq \
                --compact-output \
                --raw-output \
                '.["url"] // empty' \
            <<< "${team}"
        )"

        local teamMembersURL=''
        teamMembersURL="$(
            jq \
                --compact-output \
                --raw-output \
                '.["members_url"] // empty' \
            <<< "${team}" |
            cut -d '{' -f 1
        )"

        local teamUsers=''
        teamUsers="$(getGitTeamUsers "${user}" "${token}" "${gitURL}" "${teamMembersURL}")"

        # Find Suspended Users Walker

        local teamUsersLength="$(jq '. | length' <<< "${teamUsers}")"
        local j=0

        for ((j = 0; j < teamUsersLength; j = j + 1))
        do
            local teamUserLogin=''
            teamUserLogin="$(
                jq \
                    --compact-output \
                    --raw-output \
                    --arg jqIndex "${j}" \
                    '.[$jqIndex | tonumber] | .["login"] // empty' \
                <<< "${teamUsers}"
            )"

            if [[ "$(isGitUserSuspended "${user}" "${token}" "${gitURL}" "${teamUserLogin}")" = 'true' ]]
            then
                if [[ "${isRemoveSuspendedUsers}" = 'true' ]]
                then
                    removeGitUserFromTeam "${user}" "${token}" "${teamURL}" "${teamUserLogin}"
                    echo -e "removed suspended user \033[1;36m${teamUserLogin}\033[0m in team \033[1;32m${teamHTMLURL}\033[0m"
                else
                    if [[ "$(ldap-validate-user.bash "${teamUserLogin}")" = 'true' ]]
                    then
                        echo -e "found suspended & valid LDAP user \033[1;36m${teamUserLogin}\033[0m in team \033[1;32m${teamHTMLURL}\033[0m"
                    else
                        echo -e "found suspended & \033[1;31minvalid LDAP\033[0m user \033[1;36m${teamUserLogin}\033[0m in team \033[1;32m${teamHTMLURL}\033[0m"
                    fi
                fi
            fi
        done

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
                if [[ "${isRemoveFindUsers}" = 'true' ]]
                then
                    removeGitUserFromTeam "${user}" "${token}" "${teamURL}" "${findUser}"
                    echo -e "removed user \033[1;36m${findUser}\033[0m in team \033[1;32m${teamHTMLURL}\033[0m"
                else
                    echo -e "found user \033[1;36m${findUser}\033[0m in team \033[1;32m${teamHTMLURL}\033[0m"
                fi
            fi
        done
    done
}

function findRemoveGitRepositoriesCollaborators()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local -r gitURL="${4}"
    local -r isRemoveFindUsers="${5}"
    local -r isRemoveSuspendedUsers="${6}"
    local -r findUsers=($(sortUniqArray "${@:7}"))

    # Validation

    checkNonEmptyString "${user}" 'undefined user'
    checkNonEmptyString "${token}" 'undefined token'
    checkNonEmptyString "${orgName}" 'undefined organization name'

    # Repositories Walker

    local -r repositories=($(getGitUserRepositoryObjectKey "${user}" "${token}" 'name' 'all' "${orgName}" "${gitURL}"))
    local repository=''

    for repository in "${repositories[@]}"
    do
        local collaborators=''
        collaborators="$(getGitRepositoryCollaborators "${user}" "${token}" "${orgName}" "${repository}" "${gitURL}")"

        # Find Suspended Users Walker

        local collaboratorsLength="$(jq '. | length' <<< "${collaborators}")"
        local i=0

        for ((i = 0; i < collaboratorsLength; i = i + 1))
        do
            local collaboratorLogin=''
            collaboratorLogin="$(
                jq \
                    --compact-output \
                    --raw-output \
                    --arg jqIndex "${i}" \
                    '.[$jqIndex | tonumber] | .["login"] // empty' \
                <<< "${collaborators}"
            )"

            if [[ "$(isGitUserSuspended "${user}" "${token}" "${gitURL}" "${collaboratorLogin}")" = 'true' ]]
            then
                if [[ "${isRemoveSuspendedUsers}" = 'true' ]]
                then
                    removeGitCollaboratorFromRepository "${user}" "${token}" "${gitURL}" "${orgName}" "${repository}" "${collaboratorLogin}"
                    echo -e "removed suspended user \033[1;36m${collaboratorLogin}\033[0m in collaborators of repository \033[1;32m${repository}\033[0m"
                else
                    if [[ "$(ldap-validate-user.bash "${collaboratorLogin}")" = 'true' ]]
                    then
                        echo -e "found suspended & valid LDAP user \033[1;36m${collaboratorLogin}\033[0m in collaborators of repository \033[1;32m${repository}\033[0m"
                    else
                        echo -e "found suspended & \033[1;31minvalid LDAP\033[0m user \033[1;36m${collaboratorLogin}\033[0m in collaborators of repository \033[1;32m${repository}\033[0m"
                    fi
                fi
            fi
        done

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
                <<< "${collaborators}"
            )"

            if [[ "$(isEmptyString "${foundUser}")" = 'false' ]]
            then
                local foundUserHTMLURL=''
                foundUserHTMLURL="$(
                    jq \
                        --compact-output \
                        --raw-output \
                        '.["html_url"] // empty' \
                    <<< "${foundUser}"
                )"

                if [[ "${isRemoveFindUsers}" = 'true' ]]
                then
                    removeGitCollaboratorFromRepository "${user}" "${token}" "${gitURL}" "${orgName}" "${repository}" "${findUser}"
                    echo -e "removed user \033[1;36m${findUser}\033[0m in collaborators of repository \033[1;32m$(dirname "${foundUserHTMLURL}")/${orgName}/${repository}/settings/access\033[0m"
                else
                    echo -e "found user \033[1;36m${findUser}\033[0m in collaborators of repository \033[1;32m$(dirname "${foundUserHTMLURL}")/${orgName}/${repository}/settings/access\033[0m"
                fi
            fi
        done
    done
}

function findRemoveGitSuspendedUsers()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local -r gitURL="${4}"
    local -r isRemoveSuspendedUsers="${5}"

    local -r members="$(getGitOrganizationMembers "${user}" "${token}" "${orgName}" "${gitURL}")"
    local -r membersLength="$(jq '. | length' <<< "${members}")"
    local i=0

    for ((i = 0; i < membersLength; i = i + 1))
    do
        local memberLogin=''
        memberLogin="$(
            jq \
                --compact-output \
                --raw-output \
                --arg jqIndex "${i}" \
                '.[$jqIndex | tonumber] | .["login"] // empty' \
            <<< "${members}"
        )"

        if [[ "$(isGitUserSuspended "${user}" "${token}" "${gitURL}" "${memberLogin}")" = 'true' ]]
        then
            if [[ "${isRemoveSuspendedUsers}" = 'true' ]]
            then
                removeGitMemberFromOrganization "${user}" "${token}" "${gitURL}" "${orgName}" "${memberLogin}"
                echo -e "removed suspended user \033[1;36m${memberLogin}\033[0m from organization \033[1;32m${orgName}\033[0m"
            else
                if [[ "$(ldap-validate-user.bash "${teamUserLogin}")" = 'true' ]]
                then
                    echo -e "found suspended & valid LDAP user \033[1;36m${memberLogin}\033[0m from organization \033[1;32m${orgName}\033[0m"
                else
                    echo -e "found suspended & \033[1;31minvalid LDAP\033[0m user \033[1;36m${memberLogin}\033[0m from organization \033[1;32m${orgName}\033[0m"
                fi
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

            --user)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local user="$(trimString "${1}")"
                fi

                ;;

            --token)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local token="$(trimString "${1}")"
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
                    local gitURL="$(trimString "${1}")"
                fi

                ;;

            --remove-find-users)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local isRemoveFindUsers="$(trimString "${1}")"
                fi

                ;;

            --remove-suspended-users)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local isRemoveSuspendedUsers="$(trimString "${1}")"
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

    # Validate Tool

    checkExistCommand 'jq'

    # Validation

    checkNonEmptyString "${user}" 'undefined user'
    checkNonEmptyString "${token}" 'undefined token'
    checkNonEmptyString "${orgNames}" 'undefined organization names'
    checkNonEmptyString "${findUsers}" 'undefined find users'

    # Set Default Value

    if [[ "$(isEmptyString "${isRemoveFindUsers}")" = 'true' ]]
    then
        isRemoveFindUsers="${DEFAULT_IS_ACTION_MODE}"
    fi

    if [[ "$(isEmptyString "${isRemoveSuspendedUsers}")" = 'true' ]]
    then
        isRemoveSuspendedUsers="${DEFAULT_IS_ACTION_MODE}"
    fi

    # Validate Action Mode

    checkTrueFalseString "${isRemoveFindUsers}" "remove-find-users must be 'true' or 'false'"
    checkTrueFalseString "${isRemoveSuspendedUsers}" "remove-suspended-users must be 'true' or 'false'"

    # Organization Walker

    local orgName=''

    for orgName in "${orgNames[@]}"
    do
        orgName="$(tr '[:lower:]' '[:upper:]' <<< "${orgName}")"

        header "FINDING & REMOVING TEAM USERS IN GIT ORG ${orgName}"
        findRemoveGitOrgTeamUsers "${user}" "${token}" "${orgName}" "${gitURL}" "${isRemoveFindUsers}" "${isRemoveSuspendedUsers}" "${findUsers}"

        header "FINDING & REMOVING REPOSITORIES COLLABORATORS IN GIT ORG ${orgName}"
        findRemoveGitRepositoriesCollaborators "${user}" "${token}" "${orgName}" "${gitURL}" "${isRemoveFindUsers}" "${isRemoveSuspendedUsers}" "${findUsers}"

        header "FINDING & REMOVING SUSPENDED USERS IN GIT ORG ${orgName}"
        findRemoveGitSuspendedUsers "${user}" "${token}" "${orgName}" "${gitURL}" "${isRemoveSuspendedUsers}"
    done
}

main "${@}"