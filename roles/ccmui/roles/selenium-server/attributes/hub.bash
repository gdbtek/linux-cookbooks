#!/bin/bash -e

export ccmuiSeleniumServerDisk='/dev/sdb'
export ccmuiSeleniumServerMountOn='/opt'

export ccmuiSeleniumServerHosts=(
    '192.168.239.3  selenium-win-2.ccmui.adobe.com'
    '192.168.239.4  selenium-win-3.ccmui.adobe.com'
    '192.168.239.19 selenium-win-4.ccmui.adobe.com'
    '192.168.239.20 selenium-win-5.ccmui.adobe.com'
    '192.168.239.22 selenium-win-6.ccmui.adobe.com'
)