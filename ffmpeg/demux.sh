#! /bin/bash

#
# Command line handling
#
usage()
{
	echo "Usage: $0 <STREAM>"

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

STREAM=$1

failed_exit()
{
    echo "$0: $1"
    exit 1
}

[ -e $STREAM ] || failed_exit "$STREAM doesn't exists"

es_type=`ffprobe $STREAM 2>&1 | egrep 'Stream.*Video' | awk -F ' ' '{print $4}'`

demux_h264_hevc()
{
    es=$1

    file=${STREAM%%.*}

    ffmpeg -y -i ${STREAM} -format $es -c:v copy ${file}.$es
}

if [[ $es_type =~ h264 ]]; then
    demux_h264_hevc "h264"
elif [[ $es_type =~ hevc ]]; then   
    demux_h264_hevc "hevc"
else
    failed_exit "$STREAM stream type unrecognized"
fi
