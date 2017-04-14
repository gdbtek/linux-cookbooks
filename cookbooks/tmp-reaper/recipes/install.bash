#!/bin/bash -e

function install()
{
    umask '0022'

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        # Install

        installPackages 'tmpreaper'

        # Config Cron

        local content=''
        local i=0

        for ((i = 0; i < ${#TMP_REAPER_FOLDERS[@]}; i = i + 3))
        do
            if [[ "$(isEmptyString "${TMP_REAPER_FOLDERS[${i} + 1]}")" = 'true' ]]
            then
                content="${content}\ntmpreaper -a -f -s -v '${TMP_REAPER_FOLDERS[${i} + 2]}' '${TMP_REAPER_FOLDERS[${i}]}'"
            else
                content="${content}\ntmpreaper -a -f -s -v --protect '${TMP_REAPER_FOLDERS[${i} + 1]}' '${TMP_REAPER_FOLDERS[${i} + 2]}' '${TMP_REAPER_FOLDERS[${i}]}'"
            fi
        done

        echo -e "$(removeEmptyLines "${content}")" > "${TMP_REAPER_CRON_FOLDER}/tmp-reaper"
        chmod 755 "${TMP_REAPER_CRON_FOLDER}/tmp-reaper"
        rm -f "${TMP_REAPER_CRON_FOLDER}/.placeholder"

        echo
        cat "${TMP_REAPER_CRON_FOLDER}/tmp-reaper"
    else
        fatal 'FATAL : only support Ubuntu OS'
    fi

    umask '0077'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING TMP-REAPER'

    install
    installCleanUp
}

main "${@}"