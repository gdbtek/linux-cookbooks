#!/bin/bash -e

export WILDFLY_DOWNLOAD_URL='https://download.jboss.org/wildfly/17.0.1.Final/wildfly-17.0.1.Final.tar.gz'

export WILDFLY_INSTALL_FOLDER_PATH='/opt/wildfly'

export WILDFLY_USER_NAME='wildfly'
export WILDFLY_GROUP_NAME='wildfly'

export WILDFLY_MANAGEMENT_USER='wildfly'
export WILDFLY_MANAGEMENT_PASSWORD='wildfly'

export WILDFLY_SERVICE_NAME='wildfly'

export WILDFLY_APPLICATION_BIND_ADDRESS='0.0.0.0'
export WILDFLY_MANAGEMENT_BIND_ADDRESS='localhost'