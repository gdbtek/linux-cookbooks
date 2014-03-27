#!/bin/bash

downloadURL='http://download.redis.io/releases/redis-stable.tar.gz'
user='redis'

etcInitFile='/etc/init/redis.conf'
etcProfileFile='/etc/profile.d/redis.sh'

installFolder='/opt/redis'
installBinFolder="${installFolder}/bin"
installConfigFolder="${installFolder}/config"
installDataFolder="${installFolder}/data"

fsFileMax=100000
vmOverCommitMemory=1

requirePorts=(6379)
