#!/bin/bash
# Script displaying details of CSR files
# https://github.com/misiektoja/forklift_x509_tools

# Put path to GNU sed binary below
sed="/opt/homebrew/opt/gnu-sed/libexec/gnubin/sed"

if [ $# -lt 1 ]; then
    echo "$0 <CSR/DER/PEM file>"
    exit 1
fi

sfile=$1

filename=$(basename -- "$sfile")
extension="${filename##*.}"
extension=$(echo $extension|tr '[:lower:]' '[:upper:]')
filename="${filename%.*}"

if [ $extension = "PEM" ] || [ $extension = "CSR" ]; then
	/usr/bin/openssl req -text -in "$sfile"
elif [ $extension = "DER" ]; then
    /usr/bin/openssl req -text -inform der -in "$sfile"
else
	echo "File format not supported"
	exit 1
fi

exit 0
