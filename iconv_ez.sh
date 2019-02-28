#! /bin/bash

#
# Command line handling
#
usage()
{
    echo "Usage: $0 <file1> <file2> ..."
    echo "    automatically convert file(s) encoding from gb2312 to utf8, "
    echo "    or from utf-8 to gb2312"

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

conv_inplace()
{
    from=$1
    to=$2

    file=$3

    iconv -f $from -t $to -o $file.new $file
    mv -f $file.new $file
}

shift $((OPTIND-1))
for f in $@; do
    if ! [ -e $f ]; then
        echo "$f not exists"
        continue
    fi

    encoding=`chardet3 $f`

    # FIXME: deal with chardet3 confidence
    if [[ $encoding =~ 'GB2312' ]]; then
        echo "convert $f into utf-8 ... "
        conv_inplace gb2312 utf8 $f
        continue
    fi

    if [[ $encoding =~ 'utf-8' ]]; then
        echo "convert $f into gb2312 ... "
        conv_inplace utf8 gb2312 $f
        continue
    fi

    echo "passed $f with encoding: $encoding"
done
