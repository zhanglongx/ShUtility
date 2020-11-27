#! /bin/bash

CA_ROOT_PATH=~/Workdir/ca/root
SITE_PATH=~/Workdir/ca/bvc
SITE_NAME=bvc

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options] <IP/DNS>"
    echo "  -c CA_ROOT_PATH    CA root path [$CA_ROOT_PATH]"
    echo "  -s SITE_PATH       Site path [$SITE_PATH]"
    echo "  -n SITE_NAME       Site Name [$SITE_NAME]"

    exit 0
}

while getopts 'c:s:h' OPT; do
    case $OPT in
        c)
            CA_ROOT_PATH="$OPTARG";;
        s)
            SITE_PATH="$OPTARG";;
        n)
            SITE_NAME="$OPTARG";;
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

[ -d $CA_ROOT_PATH ] || failed_exit "$CA_ROOT_PATH not exists"
[ -e $CA_ROOT_PATH/openssl.cnf ] || failed_exit "$CA_ROOT_PATH does not contain openssl.cnf"

[ -d $SITE_PATH ] || failed_exit "$SITE_PATH not exists"
[ -e $SITE_PATH/privkey.pem ] || failed_exit "$SITE_PATH does not contain privkey.pem"
[ -e $SITE_PATH/openssl.cnf ] || failed_exit "$SITE_PATH does not contain openssl.cnf"

shift $((OPTIND-1))
IP=$1

[ x$IP != x ] || failed_exit "IP/DNS not specified"

sed -i "s/\(commonName\s*=\).*$/\1 $IP/" $SITE_PATH/openssl.cnf
# FIXME: last line thing ...
if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    sed -i "$ s/^.*$/IP.1 = $IP/" $SITE_PATH/openssl.cnf
else
    sed -i "$ s/^.*$/DNS.1 = $IP/" $SITE_PATH/openssl.cnf
fi
openssl req -new -key $SITE_PATH/privkey.pem -out $SITE_PATH/$SITE_NAME.csr -config $SITE_PATH/openssl.cnf
openssl ca -in $SITE_PATH/$SITE_NAME.csr -out $SITE_PATH/$SITE_NAME.crt -config $CA_ROOT_PATH/openssl.cnf

openssl pkcs12 -export -in $SITE_PATH/$SITE_NAME.crt -inkey $SITE_PATH/privkey.pem -out $SITE_PATH/$SITE_NAME.p12
keytool -importkeystore -srckeystore $SITE_PATH/$SITE_NAME.p12 -srcstoretype PKCS12 -destkeystore $SITE_PATH/$SITE_NAME.keystore -deststoretype JKS

