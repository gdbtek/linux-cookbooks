#!/bin/bash -e

export SSH_CONFIGS=(
    'AllowTcpForwarding yes'
    'GatewayPorts yes'
    'GSSAPIAuthentication no'
    'UseDNS no'
)