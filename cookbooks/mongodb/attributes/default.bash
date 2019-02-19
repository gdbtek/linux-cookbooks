#!/bin/bash -e

export MONGODB_DOWNLOAD_URL='https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.0.6.tgz'

export MONGODB_INSTALL_FOLDER_PATH='/opt/mongodb'
export MONGODB_INSTALL_DATA_FOLDER="${MONGODB_INSTALL_FOLDER_PATH}/data"

export MONGODB_SERVICE_NAME='mongodb'

export MONGODB_USER_NAME='mongodb'
export MONGODB_GROUP_NAME='mongodb'

export MONGODB_PORT='27017'