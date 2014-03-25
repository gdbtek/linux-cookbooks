#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y build-essential
    apt-get install -y curl
    apt-get install -y libpcre3-dev
    apt-get install -y libssl-dev
}

function install()
{
    local currentPath="$(pwd)"
    local tempFolder="$(mktemp -d)"

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${tempFolder}"

    addSystemUser "${user}"
    cd "${tempFolder}"
    ./configure --user="${user}" --group="${user}" --prefix="${installFolder}" --with-http_ssl_module
    make
    make install

    rm -rf "${tempFolder}"
    cd "${currentPath}"

    echo "export PATH=\"${installFolder}/sbin:\$PATH\"" > "${etcProfileFile}"
    cp -f "${appPath}/../files/upstart/nginx.conf" "${etcInitFile}"
    cp -f "${appPath}/../files/conf/nginx.conf" "${installConfigFolder}"

    start "$(getFileName "${etcInitFile}")"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING NGINX'

    checkRequireRootUser
    installDependencies
    install
}

main "${@}"
