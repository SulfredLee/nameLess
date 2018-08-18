#!/bin/bash
SRC_DIR=$(pwd)
DST_DIR=$(pwd)
ProtoFile=$(ls *.proto)
Bin="/usr/local/protobuf/3.6.0/bin/protoc"

$Bin -I=$SRC_DIR --cpp_out=$DST_DIR $SRC_DIR/addressbook.proto
