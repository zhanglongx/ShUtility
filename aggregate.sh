#! /bin/sh

set -x

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options] <directory>"

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

shift $((OPTIND-1))
XLS_PATH=$1

[ x$XLS_PATH != x ] || failed_exit "XLS_PATH not given"
[ -d $XLS_PATH ] || failed_exit "$XLS_PATH not exists"

[ -x "$(command -v xlsx2csv)" ] || failed_exit "xlsx2csv not found"
[ -x "$(command -v perl)" ] || failed_exit "perl not found"
[ -x "$(command -v iconv)" ] || failed_exit "iconv not found"

for f in `find $XLS_PATH -name '*xls*'`; do
    xlsx2csv $f | perl -ne "print if /,[124]\d{4,4},/" >> aggregate.csv.tmp
done

sed -ie "s/\"//g" aggregate.csv.tmp

iconv -f utf8 -t gb2312 -o aggregate.csv aggregate.csv.tmp
echo "aggregated:\n"
wc -l aggregate.csv

rm aggregate.csv.tmp
