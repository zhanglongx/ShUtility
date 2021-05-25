#! /bin/bash

failed_exit()
{
    echo "$0: $1"
    exit 1
}

gb2312_to_utf-8()
{
    gbfiles=`find . -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' | xargs chardet3 | egrep GB2312 | awk -F ':' '{print $1}'`

    for f in $gbfiles; do
        echo "iconv $f ... "
        iconv -f gb2312 -t utf-8 -o $f.new $f
        mv -f $f.new $f
    done
}

gb2312_to_utf-8