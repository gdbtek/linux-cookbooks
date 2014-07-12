#!/bin/bash

haproxyDownloadURL='http://www.haproxy.org/download/1.5/src/haproxy-1.5.1.tar.gz'

haproxyInstallFolder='/opt/haproxy'

haproxyServiceName='haproxy'

haproxyUID='haproxy'
haproxyGID='haproxy'

haproxyPort=80

haproxyTarget='custom'
haproxyCPU='native'
haproxyUsePCRE=1
haproxyUseOpenSSL=1
haproxyUserZLIB=1