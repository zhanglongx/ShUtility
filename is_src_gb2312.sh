#! /bin/bash

files=`find . -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp'`

for f in $files; do 
    chardet3 $f | egrep GB2312
done