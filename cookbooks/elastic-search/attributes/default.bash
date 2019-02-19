#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export ELASTIC_SEARCH_DOWNLOAD_URL='https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.6.1.tar.gz'

export ELASTIC_SEARCH_INSTALL_FOLDER_PATH='/opt/elastic-search'
export ELASTIC_SEARCH_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"

export ELASTIC_SEARCH_SERVICE_NAME='elastic-search'

export ELASTIC_SEARCH_USER_NAME='elastic'
export ELASTIC_SEARCH_GROUP_NAME='elastic'