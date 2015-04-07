#!/bin/bash -e

export mysqlDownloadURL='http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.24-linux-glibc2.5-x86_64.tar.gz'

export mysqlInstallFolder='/opt/mysql'

export mysqlUserName='mysql'
export mysqlGroupName='mysql'

export mysqlServiceName='mysql'

export mysqlPort='3306'

export mysqlRunPostSecureInstallation='true'

export mysqlRootPassword=''
export mysqlDeleteAnonymousUsers='true'
export mysqlDisallowRootLoginRemotely='true'
export mysqlDeleteTestDatabase='true'
export mysqlReloadPrivilegeTable='true'