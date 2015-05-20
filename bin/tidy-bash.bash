#!/bin/bash -e

function main()
{
    "$(dirname "${BASH_SOURCE[0]}")/beautify-bash.bash"
    "$(dirname "${BASH_SOURCE[0]}")/validate-bash.bash"
}

main "${@}"