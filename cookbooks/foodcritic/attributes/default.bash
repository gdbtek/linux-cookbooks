#!/bin/bash -e

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../../ruby/attributes/default.bash"

export FOODCRITIC_RUBY_INSTALL_FOLDER="${RUBY_INSTALL_FOLDER}"