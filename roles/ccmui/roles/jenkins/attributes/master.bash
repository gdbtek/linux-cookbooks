#!/bin/bash -e

ccmuiJenkinsDisk='/dev/sdb'
ccmuiJenkinsMountOn='/opt'

ccmuiJenkinsGITUserName='Nam Nguyen'
ccmuiJenkinsGITUserEmail='namnguye@adobe.com'

ccmuiJenkinsInstallPlugins=(
    'htmlpublisher'
    'selenium'
    'testng-plugin'
)