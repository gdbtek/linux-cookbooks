#!/bin/bash

downloadURL='http://nginx.org/download/nginx-1.5.12.tar.gz'
user='nginx'

etcInitFolder='/etc/init'
etcProfileFile='/etc/profile.d/nginx.sh'

installFolder='/opt/nginx'
configFolder="${installFolder}/conf"
