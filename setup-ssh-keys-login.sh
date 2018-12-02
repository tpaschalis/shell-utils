#!/bin/sh

# $1 : user@host
# initial user@host for passwordless login

s="~/.ssh"
ak=$s/authorized_keys

ssh $1 "mkdir -p $s; chmod 700 $s; touch $ak; chmod 640 $ak"
cat ~/.ssh/id_rsa.pub | ssh $1 "cat >> $ak"
