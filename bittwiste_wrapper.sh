#! /bin/sh

# wrapper for bittwiste

BT=bittwiste

usage()
{
    echo "Usage: $0 -i <ip in> -p <ip out> -t <eth out> in.pcap out.pcap"
    exit 1
}

while getopts 'i:p:t:h' OPT; do
    case $OPT in
        i)
            IP_IN="$OPTARG";;
        p)
            IP_OUT="$OPTARG";;
        t)
            ETH_OUT="$OPTARG";;
        h)
            usage;;
        ?)
            usage;;
    esac
done

shift $((OPTIND-1))

IN_PCAP=$1
OUT_PCAP=$2

[ $1 != '-h' -a $1 != '--help' ] || usage
[ x$IN_PCAP != x ] || usage
[ x$OUT_PCAP != x ] || usage

[ -e $IN_PCAP ] || usage

[ x$IP_IN != x ] || usage
[ x$IP_OUT != x ] || usage
[ x$ETH_OUT != x ] || usage

$BT -I $IN_PCAP -O tmp.pcap -T ip -s ,$IP_IN -d ,$IP_OUT && \
    $BT -I tmp.pcap -O $OUT_PCAP -T eth -d $ETH_OUT

rm -f tmp.pcap
