#! /usr/bin/env bash

# set -x

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options] PATH"
    echo "  -i     		  print info only"
	echo "  converts a git repository all text file(s) to LF and utf-8 (noBOM)"
	echo ""
	echo "NOTE: all not UTF-8 is treated as GB2312, it may lead"
	echo "		ill-decision"
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
RET_NOBOM=1
isUTF8()
{
	file=$1

	[ -e $file ] || return

	RET_UTF8=0
	RET_NOBOM=1

	if chardet3 $file | egrep -iq '(utf|ascii)'; then
		RET_UTF8=1
	fi

	if chardet3 $file | egrep -iq 'utf-8-sig'; then
		RET_NOBOM=0
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

	if [ $RET_ISLF = 0 ] || [ $RET_UTF8 = 0 ] || [ $RET_NOBOM = 0 ]; then
		echo "$f LF: $RET_ISLF UTF-8: $RET_UTF8 noBOM: $RET_NOBOM"
		if [ $ARG_INFO = 0 ]; then
			read -p "Convert $f into lf and utf-8 (noBOM) [y/n]" choice
			if [ $choice = 'y' ]; then
				if [ $RET_ISLF = 0 ]; then
					dos2unix $f
				fi

				if [ $RET_UTF8 = 0 ]; then
					# FIXME:
					iconv -f gb2312 -t utf8 -o ${f}.new $f
					mv -f ${f}.new $f
				fi

				if [ $RET_NOBOM = 0 ]; then
					sed -i '1s/^\xEF\xBB\xBF//' $f
				fi
			fi
		fi
	fi
done