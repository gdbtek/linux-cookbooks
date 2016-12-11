#!/bin/bash -e

export MONGODB_DOWNLOAD_URL='https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.4.0.tgz'

export MONGODB_INSTALL_FOLDER='/opt/mongodb'
export MONGODB_INSTALL_DATA_FOLDER="${MONGODB_INSTALL_FOLDER}/data"

export MONGODB_SERVICE_NAME='mongodb'

export MONGODB_USER_NAME='mongodb'
export MONGODB_GROUP_NAME='mongodb'

export MONGODB_PORT='27017'