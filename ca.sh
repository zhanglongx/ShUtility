#! /bin/sh

SVN_REPO_DEFAULT=/home/git/work/Tegra
GIT_REPO_DEFAULT=/home/git/repo/Tegra
ADD_SVN_REPO=/home/git/work/add_svn_repo.sh

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options] NAME"
    echo "  -u SVN_URL    svn url"
    echo "  -s SVN_REPO   svn repo [$SVN_REPO_DEFAULT]"
    echo "  -g GIT_REPO   git repo [$GIT_REPO_DEFAULT]"
    echo "  SVN_URL or SVN_REPO *must* be given"

    exit 0
}

while getopts 'u:s:g:h' OPT; do
    case $OPT in
        u)
            SVN_URL="$OPTARG";;
        s)
            SVN_REPO="$OPTARG";;
        g)
            GIT_REPO="$OPTARG";;
        h)
            usage;;
        ?)
            usage;;
    esac
done

# SVN authentic
SVN_USER=
SVN_PASS=

failed_exit()
{
    echo "$0: $1"
    exit 1
}

test x$SVN_REPO != x || SVN_REPO=$SVN_REPO_DEFAULT

test x$SVN_URL != x -o x$SVN_REPO != x || usage
test x$GIT_REPO != x || GIT_REPO=$GIT_REPO_DEFAULT

test `whoami` = 'git' || failed_exit "$0 must run under account 'git'"

sub_git()
{
    name=$1
    url=$2

    # append .git
    test $name != ${name%*.git} || name=$name.git

    name=$GIT_REPO/$name

    if test -d $name; then
        echo "$name already exist" 
        return 1
    fi

    mkdir -p $name

    subgit configure --layout auto --trunk trunk $url $name && \
        printf "\n$SVN_USER $SVN_PASS\n" >> $name/subgit/passwd && \
        sed -i 's/shared = false/shared = true/' $name/subgit/config && \
        subgit install $name 

    cd $name && git config core.sharedRepository group

    name=`basename $name`
    echo "$name installed successfully"

    return 0
}

if test x$SVN_REPO != x; then
    __svn_url=`svn info --show-item url $SVN_REPO`
    test $? = 0 || failed_exit "$SVN_REPO is no a svn repo"
fi

test -d $GIT_REPO || failed_exit "$GIT_REPO does not exist"

shift $((OPTIND-1))
for name in $@; do
    if test x$SVN_URL != x; then
        sub_git $name $SVN_URL
    elif test x$SVN_REPO != x; then
        name=${name%*.git}
        $ADD_SVN_REPO $SVN_REPO $name
        sub_git $name $__svn_url/$name
    fi
done
