#! /usr/bin/env bash

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options]"
    echo "  -t PRIVATE-TOKEN"

    exit 0
}

while getopts 't:h' OPT; do
    case $OPT in
        t)
            TOKEN="$OPTARG";;
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

[ x$TOKEN != x ] || failed_exit "no token given"

[ -d .tmp ] || mkdir -p .tmp

rm -rf .tmp/*

PROJECTS=(
    # Web & framework
    "613,qt_terminal"
    "1024,web-lq"
    "851,zh-admin"
    "805,xingjie-web"
    "852,zh-client2.0"
    "912,business-terminal"

    # tetris-2.0
    "799,tetris2.0"

    # venus
    "942,MatrixJoiner"
    "1025,Suma9XDeviceJoiner"
    "988,DeviceMaintenceService"
    "1037,KSSDevJoiner"
    "941,StreamTransporter "

    # etc
    "1051,zh-xingjie-cascade-system"
    "894,XingJieSDK"
    "968,ScreenCaptureService"
)

download_zip() {
    id=$1
    name=$2

    curl --header "PRIVATE-TOKEN: $TOKEN" \
         "http://gitlab.rd.smsx.tech/api/v4/projects/$id/repository/archive.zip" \
         --output .tmp/$name.zip
}

declare -A duplicate

for p in ${PROJECTS[@]}; do
    id=${p%,*}
    name=${p#*,}

    if [[ -n "${duplicate[$id]}" ]]; then
        echo "$id: $name already exist"
        continue
    fi

    download_zip $id $name

    duplicate[$id]=1
done