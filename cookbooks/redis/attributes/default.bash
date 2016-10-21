#!/bin/bash -e

export REDIS_DOWNLOAD_URL='http://download.redis.io/releases/redis-stable.tar.gz'

export REDIS_SERVICE_NAME='redis'

export REDIS_USER_NAME='redis'
export REDIS_GROUP_NAME='redis'

export REDIS_PORT='6379'

export REDIS_INSTALL_BIN_FOLDER='/opt/redis/bin'
export REDIS_INSTALL_CONFIG_FOLDER='/opt/redis/config'
export REDIS_INSTALL_DATA_FOLDER='/opt/redis/data'

export REDIS_VM_OVER_COMMIT_MEMORY='1'