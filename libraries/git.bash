#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/util.bash"

function checkValidGitToken()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r gitURL="${3}"

    if [[ "$(isValidGitToken "${user}" "${token}" "${gitURL}")" = 'false' ]]
    then
        fatal '\nFATAL : invalid token'
    fi
}

function getGitOrganizationMembers()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local gitURL="${4}"

    # Default Values

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Validation

    checkValidGitToken "${user}" "${token}" "${gitURL}"

    # Pagination

    local members='[]'
    local page=1
    local exitCount=0

    for ((page = 1; page > exitCount; page = page + 1))
    do
        local currentMembers=''
        currentMembers="$(
            curl \
                -s \
                -X 'GET' \
                -u "${user}:${token}" \
                -L "${gitURL}/orgs/${orgName}/members?page=${page}&per_page=100" \
                --retry 12 \
                --retry-delay 5 |
            jq \
                --compact-output \
                --raw-output \
                '. // empty'
        )"

        if [[ "${currentMembers}" = '[]' ]]
        then
            exitCount="$((page + 1))"
            echo "${members}"
        else
            local members="$(
                jq \
                    -S \
                    --compact-output \
                    --raw-output \
                    --argjson jqCurrentUsers "${currentMembers}" \
                    --argjson jqUsers "${members}" \
                    -n '$jqCurrentUsers + $jqUsers | unique_by(.["id"]) // empty'
            )"
        fi
    done
}

function getGitOrganizationMembersRoles()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local gitURL="${4}"

    local -r memberLogins=($(
        jq \
            --compact-output \
            --raw-output \
            '.[] | .["login"] // empty' <<< "$(getGitOrganizationMembers "${user}" "${token}" "${orgName}" "${gitURL}")" |
        sort -f -u
    ))

    local memberLogin=''

    for memberLogin in "${memberLogins[@]}"
    do
        local memberRole="$(
            curl \
                -s \
                -X 'GET' \
                -u "${user}:${token}" \
                -L "${gitURL}/orgs/${orgName}/memberships/${memberLogin}" \
                --retry 12 \
                --retry-delay 5 |
            jq \
                --compact-output \
                --raw-output \
                '.["role"] // empty'
        )"

        echo "${memberLogin}:${memberRole}"
    done
}

function getGitOrganizationTeams()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local gitURL="${4}"

    # Default Values

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Validation

    checkNonEmptyString "${orgName}" 'undefined organization name'
    checkValidGitToken "${user}" "${token}" "${gitURL}"

    # Pagination

    local teams='[]'
    local page=1
    local exitCount=0

    for ((page = 1; page > exitCount; page = page + 1))
    do
        local currentTeams=''
        currentTeams="$(
            curl \
                -s \
                -X 'GET' \
                -u "${user}:${token}" \
                -L "${gitURL}/orgs/${orgName}/teams?page=${page}&per_page=100" \
                --retry 12 \
                --retry-delay 5 |
            jq \
                --compact-output \
                --raw-output \
                '. // empty'
        )"

        if [[ "${currentTeams}" = '[]' ]]
        then
            exitCount="$((page + 1))"
            echo "${teams}"
        else
            local teams="$(
                jq \
                    -S \
                    --compact-output \
                    --raw-output \
                    --argjson jqCurrentTeams "${currentTeams}" \
                    --argjson jqTeams "${teams}" \
                    -n '$jqCurrentTeams + $jqTeams | unique_by(.["id"]) // empty'
            )"
        fi
    done
}

function getGitPrivateRepositorySSHURL()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local -r gitURL="${4}"

    getGitUserRepositoryObjectKey "${user}" "${token}" 'ssh_url' 'private' "${orgName}" "${gitURL}"
}

function getGitPublicRepositorySSHURL()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local -r gitURL="${4}"

    getGitUserRepositoryObjectKey "${user}" "${token}" 'ssh_url' 'public' "${orgName}" "${gitURL}"
}

function getGitRepositoryCollaborators()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local -r repository="${4}"
    local gitURL="${5}"

    # Default Values

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Validation

    checkValidGitToken "${user}" "${token}" "${gitURL}"
    checkNonEmptyString "${repository}" 'undefined repository'

    # Pagination

    local users='[]'
    local page=1
    local exitCount=0

    for ((page = 1; page > exitCount; page = page + 1))
    do
        local currentUsers=''
        currentUsers="$(
            curl \
                -s \
                -X 'GET' \
                -u "${user}:${token}" \
                -L "${gitURL}/repos/${orgName}/${repository}/collaborators?affiliation=all&page=${page}&per_page=100" \
                --retry 12 \
                --retry-delay 5 |
            jq \
                --compact-output \
                --raw-output \
                '. // empty'
        )"

        if [[ "${currentUsers}" = '[]' ]]
        then
            exitCount="$((page + 1))"
            echo "${users}"
        else
            local users="$(
                jq \
                    -S \
                    --compact-output \
                    --raw-output \
                    --argjson jqCurrentUsers "${currentUsers}" \
                    --argjson jqUsers "${users}" \
                    -n '$jqCurrentUsers + $jqUsers | unique_by(.["id"]) // empty'
            )"
        fi
    done
}

function getGitRepositoryNameFromCloneURL()
{
    local -r cloneURL="${1}"

    checkNonEmptyString "${cloneURL}" 'undefined clone url'

    if [[ "$(grep -F -o '@' <<< "${cloneURL}")" != '' ]]
    then
        awk -F '/' '{ print $2 }' <<< "${cloneURL}" | rev | cut -d '.' -f 2- | rev
    else
        awk -F '/' '{ print $5 }' <<< "${cloneURL}" | rev | cut -d '.' -f 2- | rev
    fi
}

function getGitTeamUsers()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r orgName="${3}"
    local -r teamName="${4}"
    local gitURL="${5}"

    # Default Values

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Validation

    checkValidGitToken "${user}" "${token}" "${gitURL}"

    # Pagination

    local users='[]'
    local page=1
    local exitCount=0

    for ((page = 1; page > exitCount; page = page + 1))
    do
        local currentUsers=''
        currentUsers="$(
            curl \
                -s \
                -X 'GET' \
                -u "${user}:${token}" \
                -L "${gitURL}/orgs/${orgName}/teams/${teamName}/members?page=${page}&per_page=100" \
                --retry 12 \
                --retry-delay 5 |
            jq \
                --compact-output \
                --raw-output \
                '. // empty'
        )"

        if [[ "${currentUsers}" = '[]' ]]
        then
            echo "${users}"
            exitCount="$((page + 1))"
        else
            local users="$(
                jq \
                    -S \
                    --compact-output \
                    --raw-output \
                    --argjson jqCurrentUsers "${currentUsers}" \
                    --argjson jqUsers "${users}" \
                    -n '$jqCurrentUsers + $jqUsers | unique_by(.["id"]) // empty'
            )"
        fi
    done
}

function getGitUserName()
{
    local -r user="${1}"
    local -r token="${2}"
    local gitURL="${3}"

    # Default Value

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Validation

    checkValidGitToken "${user}" "${token}" "${gitURL}"

    # Get User Name

    curl \
        -s \
        -X 'GET' \
        -u "${user}:${token}" \
        -L "${gitURL}/user" \
        --retry 12 \
        --retry-delay 5 |
    jq \
        --compact-output \
        --raw-output \
        --sort-keys \
        '.["name"] // empty'
}

function getGitUserPrimaryEmail()
{
    local -r user="${1}"
    local -r token="${2}"
    local gitURL="${3}"

    # Default Values

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Validation

    checkValidGitToken "${user}" "${token}" "${gitURL}"

    # Pagination

    local page=1
    local exitCount=0

    for ((page = 1; page > exitCount; page = page + 1))
    do
        local emails=''
        emails="$(
            curl \
                -s \
                -X 'GET' \
                -u "${user}:${token}" \
                -L "${gitURL}/user/emails?page=${page}&per_page=100" \
                --retry 12 \
                --retry-delay 5 |
            jq \
                --compact-output \
                --raw-output \
                --sort-keys \
                '.[] // empty' \
        )"

        local primaryEmail=''
        primaryEmail="$(
            jq \
                --compact-output \
                --raw-output \
                --sort-keys \
                'select(.["primary"] == true) |
                 .["email"] // empty' \
            <<< "${emails}"
        )"

        if [[ "$(isEmptyString "${primaryEmail}")" = 'false' || "$(isEmptyString "${emails}")" = 'true' ]]
        then
            echo "${primaryEmail}"
            exitCount="$((page + 1))"
        fi
    done
}

function getGitUserRepositoryObjectKey()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r objectKey="${3}"
    local -r kind="${4}"
    local -r orgName="${5}"
    local gitURL="${6}"

    # Default Value

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Validation

    checkNonEmptyString "${objectKey}" 'undefined object key'
    checkValidGitToken "${user}" "${token}" "${gitURL}"

    # Pagination

    local results=''
    local page=1
    local exitCount=0

    for ((page = 1; page > exitCount; page = page + 1))
    do
        # User or Organization

        if [[ "$(isEmptyString "${orgName}")" = 'true' ]]
        then
            local targetURL="${gitURL}/user/repos?affiliation=owner&page=${page}&per_page=100&visibility=${kind}"
        else
            local targetURL="${gitURL}/orgs/${orgName}/repos?page=${page}&per_page=100&type=${kind}"
        fi

        # Retrieve Objects

        local currentObjectValue=''
        currentObjectValue="$(
            curl \
                -s \
                -X 'GET' \
                -u "${user}:${token}" \
                -L "${targetURL}" \
                --retry 12 \
                --retry-delay 5 |
            jq \
                --arg jqObjectKey "${objectKey}" \
                --compact-output \
                --raw-output \
                --sort-keys \
                '.[] |
                .[$jqObjectKey] // empty'
        )"

        if [[ "$(isEmptyString "${currentObjectValue}")" = 'true' ]]
        then
            exitCount="$((page + 1))"
        elif [[ "${page}" = '1' ]]
        then
            results="$(printf '%s' "${currentObjectValue}")"
        else
            results="$(printf '%s\n%s' "${results}" "${currentObjectValue}")"
        fi
    done

    # Return Results

    echo "${results}" | sort -f
}

function isGitRepositoryExist()
{
    local -r user="${1}"
    local -r token="${2}"
    local gitURL="${3}"
    local -r orgName="${4}"
    local -r repository="${5}"

    # Default Values

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Check Status

    local -r statusCode="$(
        curl \
            --fail \
            --location "${gitURL}/repos/${orgName}/${repository}" \
            --output '/dev/null' \
            --request 'GET' \
            --retry '12' \
            --retry-delay '5' \
            --silent \
            --user "${user}:${token}" \
            --write-out "%{http_code}"
    )"

    if [[ "${statusCode}" = '200' ]]
    then
        echo 'true' && return 0
    else
        echo 'false' && return 1
    fi
}

function isGitUserSuspended()
{
    local -r user="${1}"
    local -r token="${2}"
    local gitURL="${3}"
    local -r login="${4}"

    # Default Values

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Check Status

    local -r suspendedAt="$(
        curl \
            -s \
            -X 'GET' \
            -u "${user}:${token}" \
            -L "${gitURL}/users/${login}" \
            --retry 12 \
            --retry-delay 5 |
        jq \
            --compact-output \
            --raw-output \
            '.["suspended_at"] // empty'
    )"

    if [[ "$(isEmptyString "${suspendedAt}")" = 'false' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function isValidGitToken()
{
    local -r user="${1}"
    local -r token="${2}"
    local gitURL="${3}"

    # Default Values

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Validation

    local -r result="$(
        curl \
            -s \
            -X 'GET' \
            -u "${user}:${token}" \
            -L "${gitURL}" \
            --retry 12 \
            --retry-delay 5 |
        jq \
            --compact-output \
            --raw-output \
            --sort-keys \
            '.["message"] // empty'
    )"

    if [[ "${result}" = 'Bad credentials' ]]
    then
        echo 'false' && return 1
    fi

    echo 'true' && return 0
}

function removeGitCollaboratorFromRepository()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r gitURL="${3}"
    local -r orgName="${4}"
    local -r repository="${5}"
    local -r collaborator="${6}"

    curl \
        -s \
        -X 'DELETE' \
        -u "${user}:${token}" \
        -L "${gitURL}/repos/${orgName}/${repository}/collaborators/${collaborator}" \
        --retry 12 \
        --retry-delay 5
}

function removeGitMemberFromOrganization()
{
    local -r user="${1}"
    local -r token="${2}"
    local gitURL="${3}"
    local -r orgName="${4}"
    local -r member="${5}"

    # Default Values

    if [[ "$(isEmptyString "${gitURL}")" = 'true' ]]
    then
        gitURL='https://api.github.com'
    fi

    # Remove Member

    curl \
        -s \
        -X 'DELETE' \
        -u "${user}:${token}" \
        -L "${gitURL}/orgs/${orgName}/members/${member}" \
        --retry 12 \
        --retry-delay 5
}

function removeGitUserFromTeam()
{
    local -r user="${1}"
    local -r token="${2}"
    local -r teamURL="${3}"
    local -r teamUser="${4}"

    curl \
        -s \
        -X 'DELETE' \
        -u "${user}:${token}" \
        -L "${teamURL}/memberships/${teamUser}" \
        --retry 12 \
        --retry-delay 5
}