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

PROJECTS=(
    "492,Antares"
    "716,Dianbo2PlayerJoiner"
    "511,xStreamPlayer"
    "510,UserPlayerJoiner" 
    "500,Monitor_RelationService"
    "525,WSCascade"
    "522,WSV3"
)

download_zip()
{
    id=$1
    name=$2

    curl --header "PRIVATE-TOKEN: $TOKEN" \
         "http://gitlab.rd.smsx.tech/api/v4/projects/$id/repository/archive.zip" \
         --output .tmp/$name.zip
}

rm -rf .tmp/
mkdir -p .tmp

for p in ${PROJECTS[@]}; do
    id=${p%,*}
    name=${p#*,}

    download_zip $id $name
done