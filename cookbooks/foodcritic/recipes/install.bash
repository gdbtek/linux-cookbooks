#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'ruby')" = 'false' || ! -d "${FOODCRITIC_RUBY_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../ruby/recipes/install.bash" "${FOODCRITIC_RUBY_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Install

    gem install foodcritic

    if [[ -f "${FOODCRITIC_RUBY_INSTALL_FOLDER}/bin/foodcritic" ]]
    then
        ln -f -s "${FOODCRITIC_RUBY_INSTALL_FOLDER}/bin/foodcritic" '/usr/local/bin/foodcritic'
    fi

    # Display Version

    displayVersion "\n$(foodcritic --version)"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING FOODCRITIC'

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"