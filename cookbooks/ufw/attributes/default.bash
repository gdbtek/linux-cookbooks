#!/bin/bash -e

export UFW_POLICIES=(
    'allow 22/tcp'
    'allow 80/tcp'
    'allow 443/tcp'
)