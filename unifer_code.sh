#! /usr/bin/env bash

# set -x

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options] PATH"
    echo "  -i     		  print info only"
	echo "  convert a git repository text file(s) to LF and utf-8"
    echo "  PATH *must* be given"

    exit 0
}

ARG_INFO=0
while getopts 'ih' OPT; do
    case $OPT in
        i)
            ARG_INFO=1;;
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

RET_ISTEXT=0
isText()
{
	file=$1

	[ -e $file ] || return

	# FIXME
	RET_ISTEXT=0
	if file $file | egrep -iq 'text'; then
		RET_ISTEXT=1
	fi
}

RET_ISLF=0
isLF()
{
	file=$1

	[ -e $file ] || return

	lf=`dos2unix -i $file | gawk '{print $1}'`

	RET_ISLF=0
	if [ $lf = 0 ]; then
		RET_ISLF=1
	fi
}

RET_UTF8=0
isUTF8()
{
	file=$1

	[ -e $file ] || return

	RET_UTF8=0

	if chardet3 $file | egrep -iq '(utf|ascii)'; then
		RET_UTF8=1
	fi
}

shift $((OPTIND-1))
GITREPO=$1
[ x$GITREPO != x ] || failed_exit "PATH must be given"
[ -d $GITREPO/.git ] || failed_exit "$GITREPO is not a git repository"

for f in `git -C $GITREPO ls-files`; do
	f=$GITREPO/$f

	isText $f
	if [ $RET_ISTEXT = 0 ]; then
		continue
	fi

	isLF $f
	isUTF8 $f

	if [ $RET_ISLF = 0 ] || [ $RET_UTF8 = 0 ]; then
		echo "$f LF: $RET_ISLF UTF-8: $RET_UTF8"
		if [ $ARG_INFO = 0 ]; then
			read -p "Convert $f into lf and utf-8 [y/n]" choice
			if [ $choice = 'y' ]; then
				dos2unix $f

				# FIXME:
				iconv -f gb2312 -t utf8 -o ${f}.new $f
				mv -f ${f}.new $f
			fi
		fi
	fi
done