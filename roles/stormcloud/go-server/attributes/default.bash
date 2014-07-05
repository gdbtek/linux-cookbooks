#!/bin/bash

stormcloudServerPackages=(
    'nginx'
    'xmlstarlet'
)

stormcloudAgentPackages=(
    'expect'
    'libfontconfig'
    'libfontconfig-dev'
    'libfreetype6-dev'
)

stormcloudGoServerHost='go.adobecc.com'
stormcloudNPMServerHost='npm.adobecc.com'

stormcloudGitUserName='Nam Nguyen'
stormcloudGitUserEmail='namnguye@adobe.com'

stormcloudSSLCRTFile='/opt/ssl/ssl.crt'
stormcloudSSLRSAKeyFile='/opt/ssl/ssl-rsa.key'

stormcloudNPMCacheFolder='/var/lib/nginx/cache/npm'