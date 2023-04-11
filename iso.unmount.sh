#!/bin/bash

umask 077

set -e
set -u

ls -al /dev/cdrom*

sudo umount /dev/cdrom*

