#!/bin/bash -e

export redisDownloadURL='http://download.redis.io/releases/redis-stable.tar.gz'

export redisServiceName='redis'

export redisUserName='redis'
export redisGroupName='redis'

export redisPort='6379'

export redisInstallBinFolder='/opt/redis/bin'
export redisInstallConfigFolder='/opt/redis/config'
export redisInstallDataFolder='/opt/redis/data'

export redisSoftNoFileLimit='50000'
export redisHardNoFileLimit='50000'

export redisVMOverCommitMemory='1'