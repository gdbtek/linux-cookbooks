#!/bin/bash -e

export TMP_WATCH_CRON_FOLDER='/etc/cron.hourly'

export TMP_WATCH_FOLDERS=(
    '/tmp' '/tmp/vagrant-chef' '1d'
    '/var/tmp' '' '7d'
)