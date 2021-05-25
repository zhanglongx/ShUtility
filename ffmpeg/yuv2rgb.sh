#! /bin/bash

#
# Command line handling
#
usage()
{
	echo "Usage: $0 [options] <YUV_FILE> <RGB_FILE>"
    echo "  convert yuv420p to rgb24"
    echo "  -s SIZE    <WIDTH>x<HEIGHT>"

    exit 0
}

while getopts 's:h' OPT; do
    case $OPT in
        s)
            SIZE="$OPTARG";;
        h)
            usage;;
        ?)
            usage;;
    esac
done

shift $((OPTIND-1))

YUV=$1
RGB=$2

failed_exit()
{
    echo "$0: $1"
    exit 1
}

test x"$YUV" != x -a x"$RGB" != x || failed_exit "YUV_FILE and RGB_FILE cannot be null"

test -e $YUV || failed_exit "$YUV does not exists"
test x"$SIZE" != x || failed_exit "size cannot be null"

ffmpeg -s $SIZE -pix_fmt yuv420p -i $YUV -vcodec rawvideo -pix_fmt rgb24 $RGB
