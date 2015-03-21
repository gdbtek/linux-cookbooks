#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../cookbooks/node-js/attributes/default.bash"

export ccmuiNamDisk='/dev/sdb'
export ccmuiNamMountOn='/opt'

export ccmuiNamGITUserName='Nam Nguyen'
export ccmuiNamGITUserEmail='namnguye@adobe.com'

export ccmuiNamNodeJSInstallFolder="${nodejsInstallFolder}"
export ccmuiNamNodeJSVersion='v0.10.37'