#!/bin/bash -e

function removeNewlineAtEndOfFile()
{
    local repositoryFolderPath="${1}"

    find \
        "${repositoryFolderPath}" \
        -type f \
        \( \
            -name 'authorized_keys' -o \
            -name 'known_hosts' -o \
            -name "*.bash" -o \
            -name "*.conf" -o \
            -name "*.profile" -o \
            -name "*.upstart" \
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
    local repositoryFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    removeNewlineAtEndOfFile "${repositoryFolderPath}"
}

main "${@}"