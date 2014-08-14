#!/bin/bash -e

source "$(dirname "${0}")/../../jdk/attributes/default.bash" || exit 1

elasticsearchDownloadURL='https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.tar.gz'

elasticsearchInstallFolder='/opt/elastic-search'
elasticsearchJDKFolder="${jdkInstallFolder}"

elasticsearchServiceName='elastic-search'

elasticsearchUID='elastic-search'
elasticsearchGID='elastic-search'

elasticsearchHTTPPort=9200
elasticsearchTransportTCPPort=9300