#!/bin/bash
# Script displaying details of RSA/EC DER/PEM/P12/PFX private key files
# https://github.com/misiektoja/forklift_x509_tools

if [ $# -lt 1 ]; then
    echo "$0 <RSA/EC> <DER/PEM/P12/PFX file> [pkey password]"
    exit 1
fi

mode=$1
sfile=$2
password=$3

filename=$(basename -- "$sfile")
extension="${filename##*.}"
extension=$(echo $extension|tr '[:lower:]' '[:upper:]')
mode=$(echo $mode|tr '[:upper:]' '[:lower:]')
filename="${filename%.*}"

if [ $mode != "rsa" ] && [ $mode != "ec" ]; then
    echo "Mode not supported"
    exit 1
fi

if [ $extension = "PEM" ]; then
	/usr/bin/openssl $mode -text -in "$sfile" -passin pass:"$password"
elif [ $extension = "DER" || [ $extension = "PRV"]; then
    /usr/bin/openssl $mode -text -inform der -in "$sfile" -passin pass:"$password"
elif [ $extension = "P12" ] || [ $extension = "PFX" ]; then
    if [ -z "$password" ]; then
		/usr/bin/openssl pkcs12 -in "$sfile" -info -nodes -clcerts -cacerts|/usr/bin/openssl $mode -text
	else
		/usr/bin/openssl pkcs12 -in "$sfile" -info -nodes -clcerts -cacerts -passin pass:"$password"|/usr/bin/openssl $mode -text
	fi
else
	echo "File format not supported"
	exit 1
fi

exit 0
