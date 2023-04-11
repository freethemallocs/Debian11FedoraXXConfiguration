#!/bin/bash

source "${0%/*}/library.packages.sh"

umask 077

set -e
set -f
set -u

functionUpgrade
