#!/bin/bash

umask 077

set -e
set -f
set -u

# https://serverfault.com/questions/241588/how-to-automate-ssh-login-with-password
# Look into using ssh-agent if you want to try keeping your keys protected with a passphrase

read -p "Press any key once server is running" temp
sudo ssh root@192.168.1.2 "rm -v /root/.ssh/authorized_keys; rm -v /home/administrator/.ssh/authorized_keys; rm -v /home/siesta/.ssh/authorized_keys; service ssh restart; shutdown -h 0"

