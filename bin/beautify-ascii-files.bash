#!/bin/bash -e

function removeNewlineAtEndOfFile()
{
    local -r repositoryFolderPath="${1}"

    find \
        "${repositoryFolderPath}" \
        -type f \
        \( \
            -name 'authorized_keys' -o \
            -name '*.bash' -o \
            -name '*.conf' -o \
            -name 'known_hosts' -o \
            -name 'LICENSE' -o \
            -name '*.md' -o \
            -name '*.profile' \
        \) \
        \( \
            -not -path "${repositoryFolderPath}/.git/*" \
        \) \
        -print \
        -exec bash -c -e '
            for file
            do
                printf '%s' "$(< "${file}")" > "${file}"
            done' bash '{}' \;
}

function main()
{
    local -r repositoryFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    removeNewlineAtEndOfFile "${repositoryFolderPath}"
}

main "${@}"