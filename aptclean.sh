#! /bin/bash

set -eux

sudo -- sh -c 'apt autoremove -y && apt clean -y && rm -rf /var/lib/apt/lists'
