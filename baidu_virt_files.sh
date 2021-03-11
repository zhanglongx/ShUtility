#! /bin/bash

set -x

OUTPUT_DIR="/mnt/f"
SQLITE_FILE="/mnt/d/Users/zhlx/AppData/Roaming/baidu/BaiduNetdisk/users/53eb214008e09e15044b661ce42bdaff/BaiduYunCacheFileV0.db"

TARGET_DIR="baidu_virt_files"

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options] <DIR>"
    echo "  Read local cached BaiDu NetDisk Sqlite3 database and"
    echo "  create the appropriate files and directories based on"
    echo "  the file names and directory structure readed in the"
    echo "  database."
    echo "  The size of all created files will be 0."
    echo "  If <DIR> is not set, output directory will be set to"
    echo "  $OUTPUT_DIR/$TARGET_DIR. Otherwise, it will be set to"
    echo "  <DIR>/$TARGET_DIR"
    echo ""
    echo "  -s SQLITE_FILE   SQLITE File [$SQLITE_FILE]"
    echo "  "

    exit 0
}

while getopts 's:h' OPT; do
    case $OPT in
        s)
            SQLITE_FILE="$OPTARG";;
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

if command -v sqlite3 > /dev/null 2>&1; then 
    SQLITE=sqlite3
else 
    echo "No sqlite3 found, may install sqlite3 via:"
    echo "  apt install sqlite3"
    exit 1
fi

shift $((OPTIND-1))
if [ x$1 != x ]; then
    OUTPUT_DIR=$1
fi

TARGET_DIR=$OUTPUT_DIR/$TARGET_DIR

rm -rf $TARGET_DIR
mkdir -p $TARGET_DIR

if ! $SQLITE $SQLITE_FILE ".database" > /dev/null 2>&1; then
    failed_exit "Cannot open database, Baidu NetDisk is in use?"
fi

# query dir info, then mkdir
$SQLITE $SQLITE_FILE "select * from cache_file" | 
    cut -d "|" -f 3 | sort | uniq |
        sed -e "s#^#mkdir -p \"$TARGET_DIR#g" -e "s/$/\"/g" |
            sh -x

# query file info, then touch
$SQLITE $SQLITE_FILE "select * from cache_file" |
    cut -d "|" -f 3,4 | sed -e 's/|//g' |
        sed -e "s#^#touch \"$TARGET_DIR#g" -e "s/$/\"/g" |
            sh -x
