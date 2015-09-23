#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export ELASTIC_SEARCH_DOWNLOAD_URL='https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.tar.gz'

export ELASTIC_SEARCH_INSTALL_FOLDER='/opt/elastic-search'
export ELASTIC_SEARCH_JDK_INSTALL_FOLDER="${JDK_INSTALL_FOLDER}"

export ELASTIC_SEARCH_SERVICE_NAME='elastic-search'

export ELASTIC_SEARCH_USER_NAME='elastic'
export ELASTIC_SEARCH_GROUP_NAME='elastic'