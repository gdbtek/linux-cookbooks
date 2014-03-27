#!/bin/bash

downloadURL='http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.17-linux-glibc2.5-x86_64.tar.gz'
user='mysql'

etcProfileFile='/etc/profile.d/mysql.sh'
etcInitFile='/etc/init.d/mysql'

installFolder='/opt/mysql'
installBinFolder="${installFolder}/bin"

requirePorts=(3306)
