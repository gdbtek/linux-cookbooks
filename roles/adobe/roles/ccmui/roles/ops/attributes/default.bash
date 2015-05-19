#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"

export ccmuiOpsDisk='/dev/sdb'
export ccmuiOpsMountOn='/opt'

export ccmuiOpsGITUserName='Nam Nguyen'
export ccmuiOpsGITUserEmail='namnguye@adobe.com'

export ccmuiOpsNodeJSInstallFolder="${NODE_JS_INSTALL_FOLDER:?}"
export ccmuiOpsNodeJSVersion='latest'