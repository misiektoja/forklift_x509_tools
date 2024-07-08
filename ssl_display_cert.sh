#!/bin/bash
# Script displaying details of DER/PEM/CRT/CER/P12/PFX/P7B certificate files
# https://github.com/misiektoja/forklift_x509_tools

# Put path to GNU sed binary below
sed="/opt/homebrew/opt/gnu-sed/libexec/gnubin/sed"

if [ $# -lt 1 ]; then
    echo "$0 <DER/PEM/CRT/CER/P12/PFX/P7B file> [P12/PFX password]"
    exit 1
fi

sfile=$1
password=$2

filename=$(basename -- "$sfile")
extension="${filename##*.}"
extension=$(echo $extension|tr '[:lower:]' '[:upper:]')
filename="${filename%.*}"
is_pem=$(file -b "$sfile"|grep -E -i "pem|ascii")

if [[ ( $extension = "PEM" ) || ( $extension = "CRT" && -n $is_pem ) ]]; then
	$sed -n '/-----BEGIN CERTIFICATE-----/{:start /-----END CERTIFICATE-----/!{N;b start};/.*/p}' "$sfile"|/usr/bin/openssl crl2pkcs7 -nocrl -certfile /dev/stdin|/usr/bin/openssl pkcs7 -print_certs -text -noout
elif [[ ( $extension = "DER" ) || ( $extension = "CRT" && -z $is_pem ) ]]; then
    /usr/bin/openssl x509 -text -inform der -noout -in "$sfile"
elif [ $extension = "CER" ]; then
    /usr/bin/openssl x509 -text -inform der -noout -in "$sfile"
    /usr/bin/openssl x509 -text -noout -in "$sfile"
elif [ $extension = "P7B" ]; then
    /usr/bin/openssl pkcs7 -print_certs -in "$sfile"|$sed -n '/-----BEGIN CERTIFICATE-----/{:start /-----END CERTIFICATE-----/!{N;b start};/.*/p}'|/usr/bin/openssl crl2pkcs7 -nocrl -certfile /dev/stdin|/usr/bin/openssl pkcs7 -print_certs -text -noout
    /usr/bin/openssl pkcs7 -print_certs -inform DER -in "$sfile"|$sed -n '/-----BEGIN CERTIFICATE-----/{:start /-----END CERTIFICATE-----/!{N;b start};/.*/p}'|/usr/bin/openssl crl2pkcs7 -nocrl -certfile /dev/stdin|/usr/bin/openssl pkcs7 -print_certs -text -noout
elif [ $extension = "P12" ] || [ $extension = "PFX" ]; then
    if [ -z "$password" ]; then
		/usr/bin/openssl pkcs12 -in "$sfile" -info -nodes -nokeys|/usr/bin/openssl crl2pkcs7 -nocrl -certfile /dev/stdin|/usr/bin/openssl pkcs7 -print_certs -text -noout
	else
		/usr/bin/openssl pkcs12 -in "$sfile" -info -nodes -nokeys -passin pass:"$password"|/usr/bin/openssl crl2pkcs7 -nocrl -certfile /dev/stdin|/usr/bin/openssl pkcs7 -print_certs -text -noout
		/bin/cat "$sfile"|$sed -e '/-BEGIN ENCRYPTED PRIVATE KEY-/D'|$sed -e '/-END ENCRYPTED PRIVATE KEY-/D'|/usr/bin/tr -d '\n'|base64 -d|/usr/bin/openssl pkcs12 -info -nodes -nokeys -passin pass:"$password"|/usr/bin/openssl crl2pkcs7 -nocrl -certfile /dev/stdin|/usr/bin/openssl pkcs7 -print_certs -text -noout
	fi
else
	echo "File format not supported"
	exit 1
fi

exit 0
