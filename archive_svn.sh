#! /bin/sh

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options] svn_base"

    exit 0
}

while getopts 'h' OPT; do
    case $OPT in
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

command -v tree >/dev/null 2>&1 || failed_exit "requires tree command" 
command -v svn >/dev/null 2>&1 || failed_exit "requires svn command" 

shift $((OPTIND-1))
svn_base=$1

[ x$svn_base != x ] || failed_exit "requires svn_base"

DIRS=`svn list $svn_base`

for dir in $DIRS; do
    svn_url=$svn_base/$dir

    base=${svn_base##*/}
    dir=${dir%/}

    svn export $svn_url $dir

    tree $dir > $base.$dir.txt

    tar --remove-files -cjf $base.$dir.tar.bz2 $dir
done
