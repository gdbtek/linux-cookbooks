#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../node-js/attributes/default.bash"

ghostDownloadURL='https://ghost.org/zip/ghost-latest.zip'

ghostInstallFolder='/opt/ghost'
ghostNodeJSInstallFolder="${nodejsInstallFolder}"

ghostServiceName='ghost'

ghostUserName='ghost'
ghostGroupName='ghost'

ghostProductionURL='http://127.0.0.1'
ghostProductionHost='127.0.0.1'
ghostProductionPort='2368'

ghostDevelopmentURL='http://127.0.0.1'
ghostDevelopmentHost='127.0.0.1'
ghostDevelopmentPort='2368'

ghostTestingURL='http://127.0.0.1:2369'
ghostTestingHost='127.0.0.1'
ghostTestingPort='2369'

ghostEnvironment='production'
# ghostEnvironment='development'