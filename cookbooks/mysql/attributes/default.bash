#!/bin/bash -e

mysqlDownloadURL='http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.20-linux-glibc2.5-x86_64.tar.gz'

mysqlInstallFolder='/opt/mysql'

mysqlUserName='mysql'
mysqlGroupName='mysql'

mysqlServiceName='mysql'

mysqlPort=3306

mysqlRootPassword=''
mysqlRemoveAnonymousUsers='true'
mysqlDisallowRootLoginRemotely='true'
mysqlRemoveTestDatabase='true'
mysqlReloadPrivilegeTable='true'