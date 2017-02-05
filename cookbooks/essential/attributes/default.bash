#!/bin/bash -e

export APT_ESSENTIAL_PACKAGES=(
    'bzip2'
    'curl'
    'dialog'
    'git'
    'iptables'
    'libfontconfig'
    'logrotate'
    'lsb-release'
    'lsof'
    'netcat'
    'rsync'
    'screen'
    'software-properties-common'
    'sysv-rc-conf'
    'tree'
    'unzip'
    'w3m'
    'wget'
)

export RPM_ESSENTIAL_PACKAGES=(
    'bzip2'
    'curl'
    'dialog'
    'fontconfig'
    'git'
    'iptables'
    'logrotate'
    'lsof'
    'nc'
    'rsync'
    'screen'
    'tree'
    'unzip'
    'wget'
)