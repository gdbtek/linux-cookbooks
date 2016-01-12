#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'ruby')" = 'false' || ! -d "${FOODCRITIC_RUBY_INSTALL_FOLDER}" ]]
    then
        "${appFolderPath}/../../ruby/recipes/install.bash" "${FOODCRITIC_RUBY_INSTALL_FOLDER}"
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

    info "\n$(foodcritic --version)"
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING FOODCRITIC'

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"