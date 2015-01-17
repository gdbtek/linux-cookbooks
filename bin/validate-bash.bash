#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../libraries/util.bash"

    local command='shellcheck'

    checkExistCommand "${shellcheck}" "command '${shellcheck}' not found. Run '${appPath}/cookbooks/shell-check/recipes/install.bash' to install"

    find "${appPath}/.." -type f -name "*.bash" -exec "${shellcheck}" -s bash {} \;
}

main "${@}"