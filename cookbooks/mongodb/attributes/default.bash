#!/bin/bash

downloadURL='http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.4.9.tgz'
user='mongodb'

etcInitFile='/etc/init/mongodb.conf'
etcProfileFile='/etc/profile.d/mongodb.sh'

installFolder='/opt/mongodb'
installDataFolder="${installFolder}/data"
