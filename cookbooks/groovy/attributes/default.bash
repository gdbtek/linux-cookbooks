#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export groovyDownloadURL='http://dl.bintray.com/groovy/maven/groovy-binary-2.4.3.zip'

export groovyInstallFolder='/opt/groovy'
export groovyJDKInstallFolder="${jdkInstallFolder}"