#! /bin/bash

#
# Command line handling
#
usage()
{
    echo "Usage: $0 <.ts1> <.ts2>"
    echo "    Demux video element stream. Demux Automatically detects element"
    echo "    type (H.264/H.265 supported now) in .ts, then demux .ts into es"

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

demux_h264_hevc()
{
    stream=$1
    es=$2

    file=${stream%%.*}

    ffmpeg -y -i ${stream} -format $es -c:v copy ${file}.$es
}

shift $((OPTIND-1))
for stream in $@; do
    [ -e $stream ] || failed_exit "$stream doesn't exists"

    if [ ${stream##*.} != 'ts' ]; then
        echo "$stream is not .ts"
        continue
    fi

    es_type=`ffprobe $stream 2>&1 | egrep 'Stream.*Video' | awk -F ' ' '{print $4}'`

    if [[ $es_type =~ h264 ]]; then
        demux_h264_hevc $stream "h264"
    elif [[ $es_type =~ hevc ]]; then   
        demux_h264_hevc $stream "hevc"
    else
        failed_exit "$stream: stream type unrecognized"
    fi
done
