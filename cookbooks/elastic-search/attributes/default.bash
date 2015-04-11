#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export elasticsearchDownloadURL='https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.5.1.tar.gz'

export elasticsearchInstallFolder='/opt/elastic-search'
export elasticsearchJDKInstallFolder="${jdkInstallFolder}"

export elasticsearchServiceName='elastic-search'

export elasticsearchUserName='elastic'
export elasticsearchGroupName='elastic'

export elasticsearchHTTPPort='9200'
export elasticsearchTransportTCPPort='9300'