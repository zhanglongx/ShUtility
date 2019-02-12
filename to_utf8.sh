#! /bin/bash

#
# Command line handling
#
usage()
{
    echo "Usage: $0 <file1> <file2> ..."
    echo "    convert file(s) encoding from gb2312 to utf8"

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

shift $((OPTIND-1))
for f in $@; do
    if ! [ -e $f ]; then
        echo "$f not exists"
        continue
    fi

    if ! [[ `chardet3 $f` =~ 'GB2312' ]]; then
        echo "$f encoding is not GB2312"
        continue
    fi

    iconv -f gb2312 -t utf-8 -o $f.new $f
    mv -f $f.new $f
done
