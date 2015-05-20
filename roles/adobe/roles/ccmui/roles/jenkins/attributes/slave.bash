#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"

export ccmuiJenkinsDisk='/dev/sdb'
export ccmuiJenkinsMountOn='/opt'

export ccmuiJenkinsGITUserName='Nam Nguyen'
export ccmuiJenkinsGITUserEmail='namnguye@adobe.com'

export ccmuiJenkinsNodeJSInstallFolder="${NODE_JS_INSTALL_FOLDER}"
export ccmuiJenkinsNodeJSVersion='v0.10.38'