#!/bin/bash

BASEDIR=`pwd`
source setup.inc

echo "====================================="
echo "Building md5-hbf bitstream file"
echo ""
echo "Board: $BOARD"
echo "====================================="

cd synthesis/$BOARD/ && make -f Makefile.xst

if [ "$?" != 0 ] ; then
	echo "FAILED"
	exit 1
else
        echo "OK"
fi

cd $BASEDIR

echo "Build complete!"
