#! /usr/bin/env bash

VERSION=1.0.0

VIDEOSIZE=1920x1080
RATE=25
VCODEC=h264
ACODEC=aac
BITRATE=1024k

usage()
{
    echo "Usage: $0 [options] <output>"
    echo "  -s     		  video size, default: $VIDEOSIZE"
    echo "  -r     		  video rate, default: $RATE"
    echo "  -v     		  video codec, default: $VCODEC"
    echo "  -a     		  audio codec, default: $ACODEC"
    echo "  -b     		  bitrate, default: $BITRATE"
    echo "  -h     		  print this help"
    echo "  --version   print version"
    echo "  output *must* be given"

    exit 0
}

# check if ffmpeg exists
which ffmpeg > /dev/null 2>&1 || {
    echo "ERROR: ffmpeg not found"
    exit 1
}

UNKNOWN=()

# XXX: why not getopts? because we want parse our own arguments,
#      and prevent getopts from parsing unknown arguments
while (( $# )); do
  case $1 in
    -h|--help)
      usage
      exit
      ;;
    -s)
      if (( $# > 1 )); then
        VIDEOSIZE=$2
        shift 2
      else
        echo "ERROR: '-s' requires an argument."
        exit 1
      fi
      ;;
    -r)
      if (( $# > 1 )); then
        RATE=$2
        shift 2
      else
        echo "ERROR: '-r' requires an argument."
        exit 1
      fi
      ;;
    -v)
      if (( $# > 1 )); then
        VCODEC=$2
        shift 2
      else
        echo "ERROR: '-v' requires an argument."
        exit 1
      fi
      ;;
    -a)
      if (( $# > 1 )); then
        ACODEC=$2
        shift 2
      else
        echo "ERROR: '-a' requires an argument."
        exit 1
      fi
      ;;
    -b)
      if (( $# > 1 )); then
        BITRATE=$2
        shift 2
      else
        echo "ERROR: '-b' requires an argument."
        exit 1
      fi
      ;;
    -version|--version)
      echo "videogen version $VERSION"
      ffmpeg -version
      exit
      ;;
    -*|--*)
      UNKNOWN+=("$1")
      shift
      ;;
    *)
      UNKNOWN+=("$1")
      shift
      ;;
  esac
done

if [ $VCODEC == 'h264' ] || [ $VCODEC == 'libx264' ] ; then
    XCODECPARAM="-x264-params nal-hrd=cbr"
fi

ffmpeg -re -f lavfi -i "aevalsrc=if(eq(floor(t)\,ld(2))\,st(0\,random(4)*3000+1000))\;st(2\,floor(t)+1)\;st(1\,mod(t\,1))\;(0.6*sin(1*ld(0)*ld(1))+0.4*sin(2*ld(0)*ld(1)))*exp(-4*ld(1)) [out1]; testsrc=s=$VIDEOSIZE:rate=$RATE,drawtext=borderw=5:fontcolor=white:fontsize=30:text='%{localtime}/%{pts\:hms}':x=\(w-text_w\)/2:y=\(h-text_h-line_h\)/2 [out0]" \
      -acodec $ACODEC -vcodec $VCODEC -pix_fmt yuv420p -g $RATE \
      $XCODECPARAM \
      -b:v $BITRATE -bufsize `echo $BITRATE | perl -ne 'printf "%.0f%s", $1 * 1.5, $2 if /(\d+)([kmg])/i'` \
      ${UNKNOWN[@]}
