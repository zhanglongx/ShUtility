#! /bin/sh

# inspired by: https://developer.atlassian.com/blog/2016/01/totw-copying-a-full-git-repo/
# use local commits to duplicate a git repository
# another way than git ... --mirror

usage()
{
    echo "Usage: $0 NEW_REPO OLD_REPO"
    echo "    NEW_REPO and OLD_REPO must be given both"
    exit 1
}

NEW_REPO=$1
OLD_REPO=$2

failed_exit()
{
    echo "$0: $1"
    exit 1
}

test $1 != '-h' -a $1 != '--help' || usage
test x$OLD_REPO != x -a x$NEW_REPO != x || usage

short_name=`basename ${NEW_REPO} .git`
short_name=$short_name.old

test ! -d $short_name || failed_exit "$short_name already exist"

git clone $OLD_REPO $short_name && \
    cd $short_name && \
    git checkout master && \
    git fetch --tags && \
    git remote rm origin && \
    git remote add origin $NEW_REPO && \
    git pull --rebase origin master && \
    git push origin --all && \
    git push --tags

cd - && rm -rf $short_name
