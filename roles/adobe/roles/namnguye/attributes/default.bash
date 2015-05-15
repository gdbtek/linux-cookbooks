#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../cookbooks/node-js/attributes/default.bash"

export namnguyeDisk='/dev/sdb'
export namnguyeMountOn='/opt'

export namnguyeGITUserName='Nam Nguyen'
export namnguyeGITUserEmail='namnguye@adobe.com'

export namnguyeNodeJSInstallFolder="${nodejsInstallFolder:?}"
export namnguyeNodeJSVersion='v0.10.38'
