#! /bin/bash

d=`date '+%Y-%m-%d %H:%M:%S'`

ssh -t TX1 "sudo timedatectl set-time '$d'"