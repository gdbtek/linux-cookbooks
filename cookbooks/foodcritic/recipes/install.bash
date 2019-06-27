#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'ruby')" = 'false' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../ruby/recipes/install.bash"
    fi
}

function install()
{
    umask '0022'

    gem install foodcritic

    if [[ -f "${RUBY_INSTALL_FOLDER_PATH}/bin/foodcritic" ]]
    then
        symlinkListUsrBin "${RUBY_INSTALL_FOLDER_PATH}/bin/foodcritic"
    fi

    displayVersion "$(foodcritic --version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../../ruby/attributes/default.bash"

    header 'INSTALLING FOODCRITIC'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"