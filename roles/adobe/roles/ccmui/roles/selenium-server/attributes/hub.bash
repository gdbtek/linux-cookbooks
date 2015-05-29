#!/bin/bash -e

export CCMUI_SELENIUM_SERVER_DISK='/dev/sdb'
export CCMUI_SELENIUM_SERVER_MOUNT_ON='/opt'

export CCMUI_SELENIUM_SERVER_HOSTS=(
    '192.168.239.6  selenium-win-1.ccmui.adobe.com'
    '192.168.239.3  selenium-win-2.ccmui.adobe.com'
    '192.168.239.4  selenium-win-3.ccmui.adobe.com'
    '192.168.239.19 selenium-win-4.ccmui.adobe.com'
    '192.168.239.20 selenium-win-5.ccmui.adobe.com'
    '192.168.239.22 selenium-win-6.ccmui.adobe.com'
)