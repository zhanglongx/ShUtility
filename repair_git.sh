#! /bin/sh

usage()
{
    echo "Usage: $0"
    exit 1
}

sudo chgrp -R developer .
sudo chmod -R g+rwX .
find . -type d -exec chmod g+s '{}' +