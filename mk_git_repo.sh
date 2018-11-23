#! /bin/sh

usage()
{
    echo "Usage: $0 NEW_REPO"
    echo "    NEW_REPO must be given both"
    exit 1
}

NEW_REPO=${1}.git

failed_exit()
{
    echo "$0: $1"
    exit 1
}

test $1 != '-h' -a $1 != '--help' || usage
test x$NEW_REPO != x || usage

mkdir -p $NEW_REPO && \
    cd $NEW_REPO && \
    git init --bare && \
    git config core.sharedRepository group