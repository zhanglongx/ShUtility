#! /usr/bin/env bash

# set -x

HOST_SSH='10.1.41.214 10.1.41.215 10.1.41.216 10.1.41.217 10.1.41.218'

#
# Command line handling
#
usage()
{
    echo "Usage: $0 <command>"
    echo "  -u user   user name"
    echo "  $0 send command via ssh to multi-ssh"

    exit 0
}

while getopts 'u:h' OPT; do
    case $OPT in
        u)
            USERNAME="$OPTARG";;
        h)
            usage;;
        ?)
            usage;;
    esac
done

failed_exit()
{
    echo "$0: $1"
    exit 1
}

[ $USERNAME ] || failed_exit "no user given"

shift $((OPTIND-1))
CMD=$1

[ x"$CMD" != x ] || failed_exit "no command given"

for s in $HOST_SSH; do
    echo "ssh $USERNAME@$s \"$CMD\""
    ssh $USERNAME@$s "$CMD" 
done