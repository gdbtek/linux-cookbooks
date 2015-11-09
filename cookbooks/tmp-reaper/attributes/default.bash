#!/bin/bash -e

export TMP_REAPER_CRON_FOLDER='/etc/cron.hourly'

export TMP_REAPER_FOLDERS=(
    '/tmp' '/tmp/vagrant-chef' '1h'
    '/var/tmp' '' '30d'
)