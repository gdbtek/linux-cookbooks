#!/bin/bash -e

echo $(dirname "${BASH_SOURCE[0]}")
source "$(dirname "${BASH_SOURCE[0]}")/../../../../../cookbooks/node-js/attributes/default.bash"

export ccmuiJenkinsDisk='/dev/sdb'
export ccmuiJenkinsMountOn='/opt'

export ccmuiJenkinsGITUserName='Nam Nguyen'
export ccmuiJenkinsGITUserEmail='namnguye@adobe.com'

export ccmuiJenkinsNodeJSInstallFolder="${nodejsInstallFolder}"
export ccmuiJenkinsNodeJSVersion='v0.10.36'
