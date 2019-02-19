#!/bin/bash -e

export MYSQL_DOWNLOAD_URL='http://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.15-linux-glibc2.12-x86_64.tar.xz'

export MYSQL_INSTALL_FOLDER_PATH='/opt/mysql'

export MYSQL_USER_NAME='mysql'
export MYSQL_GROUP_NAME='mysql'

export MYSQL_SERVICE_NAME='mysql'

export MYSQL_PORT='3306'

export MYSQL_RUN_POST_SECURE_INSTALLATION='true'

export MYSQL_ROOT_PASSWORD=''
export MYSQL_DELETE_ANONYMOUS_USERS='true'
export MYSQL_DISALLOW_ROOT_LOGIN_REMOTELY='true'
export MYSQL_DELETE_TEST_DATABASE='true'
export MYSQL_RELOAD_PRIVILEGE_TABLE='true'