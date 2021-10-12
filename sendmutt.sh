#! /bin/bash

usage()
{
    echo "Usage: $0 <to_mail> -a <file>"
    echo "shortcut for mutt, with attachment file name as title and body"
    exit 1
}

failed_exit()
{
    echo "$0: $1"
    exit 1
}

while getopts 'a:h' OPT; do
    case $OPT in
        a)
            att="$OPTARG";;
        h)
            usage;;
        ?)
            usage;;
    esac
done

[ x$att != x ] || failed_exit "Attachment MUST be given"
[ -e $att ] || failed_exit "no file: $att"

shift $((OPTIND-1))
mail=$1

echo ${att%.*} | mutt -s ${att%.*} $mail -a $att
