#!/bin/bash

umask 077

set -e
set -f
set -u

ifconfig
cdrskin --devices
xorriso -devices
