#!/bin/bash

set -eux

VCF_INPUT="${1}"
VCF_OUTPUT="${2}"

mawk '/^#/ { print $0; next } $1 ~ /^[0-9]+$/ {print $0}' "${VCF_INPUT}" > "${VCF_OUTPUT}"
