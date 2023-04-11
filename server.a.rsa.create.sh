#!/bin/bash

umask 077

set -e
set -f
set -u

# https://serverfault.com/questions/241588/how-to-automate-ssh-login-with-password
# Look into using ssh-agent if you want to try keeping your keys protected with a passphrase

sudo ssh-keygen -t rsa -b 2048

read -p "Press any key once server is running" temp
sudo ssh-copy-id root@192.168.1.2
sudo ssh root@192.168.1.2 "cat /root/.ssh/authorized_keys"

