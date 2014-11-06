#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

elasticsearchDownloadURL='https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.0.tar.gz'

elasticsearchInstallFolder='/opt/elastic-search'
elasticsearchJDKInstallFolder="${jdkInstallFolder}"

elasticsearchServiceName='elastic-search'

elasticsearchUserName='elastic'
elasticsearchGroupName='elastic'

elasticsearchHTTPPort='9200'
elasticsearchTransportTCPPort='9300'