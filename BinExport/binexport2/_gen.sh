#!/bin/sh
set -e

# binexport-12-20211116-ghidra_10.0.4

protoc --objc_out=. binexport2.proto
