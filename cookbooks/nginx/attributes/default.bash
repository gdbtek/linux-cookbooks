#!/bin/bash

downloadURL='http://nginx.org/download/nginx-1.5.12.tar.gz'
user='nginx'

etcInitFile='/etc/init/nginx.conf'
etcProfileFile='/etc/profile.d/nginx.sh'

installFolder='/opt/nginx'
installConfigFolder="${installFolder}/conf"
installLogFolder="${installFolder}/logs"

requirePorts=(80)
