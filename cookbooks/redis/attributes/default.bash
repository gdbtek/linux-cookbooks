#!/bin/bash

downloadURL='http://download.redis.io/releases/redis-stable.tar.gz'

serviceName='redis'

uid='redis'
gid='redis'

port=6379

installBinFolder="/opt/redis/bin"
installConfigFolder="/opt/redis/config"
installDataFolder="/opt/redis/data"

fsFileMax=100000
vmOverCommitMemory=1
