#!/bin/bash -e

export nodejsInstallFolder='/opt/node-js'

# export nodejsVersion='v0.10.38'
export nodejsVersion='latest'

export nodejsInstallNPMPackages=(
    'forever'
    'pm2'
)