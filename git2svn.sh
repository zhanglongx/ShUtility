#! /bin/sh

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options] command"
    echo "                           "
    echo "  commit an existing git repository to an EMPTY remote svn repository."
    echo "  SVN upstreaming repository is not tracked, so sync command may be broken"
    echo "  if so."
    echo "  options:"
    echo "      -v SVN_URL    svn url"
    echo "  commands: "
    echo "      init          init a remote svn (url MUST be given)"
    echo "                    It should be ran once and only once, as git-svn will "
    echo "                    keep upstreaming svn repository info"
    echo "                    All commits come from local git repository, not remote"
    echo "      sync          synchronize remote git to upstreamed svn (run command"
    echo "                    'init' first), SVN_URL is ignored."
    echo "                    Make sure there's no dirty changes"

    exit 0
}

while getopts 'v:h' OPT; do
    case $OPT in
        v)
            SVN_URL="$OPTARG";;
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

__is_git()
{
    test -e '.git' || failed_exit 'must run under git repository'
}

__rebase_HEAD()
{
    # rebase to master for normal git repository actions
    git rebase origin/master
}

init()
{
    __svn_url=$1

    # FIXME: check
    test x$__svn_url != x || failed_exit 'SVN_URL cannot be null'

    __r_files=`svn ls -R $__svn_url 2> /dev/null`

    test x$__r_files = x || failed_exit 'remote svn is not empty'

    svn mkdir --parents $__svn_url/trunk -m "Importing git repo" &&
        git svn init $__svn_url -s &&
        git svn fetch &&
        git rebase origin/trunk &&
        git add . &&
        git rebase --continue

    git svn dcommit

    __rebase_HEAD
}

sync()
{
    # FIXME: hack for git-svn detecting
    test -e .git/refs/remotes/origin/trunk || \
        failed_exit 'not in a git-svn repository, run `git2svn init` first'

    # TODO: rebase strategy
    git pull --rebase

    # TODO: what if svn has commits?
    git rebase origin/trunk &&
        git add . &&
        git rebase --continue

    git svn dcommit

    __rebase_HEAD
}

shift $((OPTIND-1))
cmd=$1

test x$cmd != x || usage

__is_git

if test $cmd = init; then
    init $SVN_URL
elif test $cmd = sync; then
    sync
else
    echo "unsupported command: $cmd"
fi