#!/bin/bash -e

export SSH_CONFIGS=(
    'AllowTcpForwarding yes'
    'GatewayPorts yes'
    'PubkeyAuthentication yes'
)