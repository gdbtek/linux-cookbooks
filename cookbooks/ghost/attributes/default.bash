#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../node-js/attributes/default.bash"

export ghostDownloadURL='https://ghost.org/zip/ghost-latest.zip'

export ghostInstallFolder='/opt/ghost'
export ghostNodeJSInstallFolder="${nodejsInstallFolder}"
export ghostNodeJSVersion="${nodejsVersion}"

export ghostServiceName='ghost'

export ghostUserName='ghost'
export ghostGroupName='ghost'

export ghostProductionURL='http://127.0.0.1'
export ghostProductionHost='127.0.0.1'
export ghostProductionPort='2368'

export ghostDevelopmentURL='http://127.0.0.1'
export ghostDevelopmentHost='127.0.0.1'
export ghostDevelopmentPort='2368'

export ghostTestingURL='http://127.0.0.1:2369'
export ghostTestingHost='127.0.0.1'
export ghostTestingPort='2369'

export ghostEnvironment='production'
# export ghostEnvironment='development'