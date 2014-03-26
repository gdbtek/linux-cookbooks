#!/bin/bash

function install()
{
    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${installFolder}"

    echo "export PATH=\"${installFolder}/bin:\$PATH\"" > "${etcProfileFile}"
    echo "export JAVA_HOME='${installFolder}'" >> "${etcProfileFile}"
    echo "export JRE_HOME='${installFolder}/jre'" >> "${etcProfileFile}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING JDK'

    checkRequireRootUser
    install
}

main "${@}"
