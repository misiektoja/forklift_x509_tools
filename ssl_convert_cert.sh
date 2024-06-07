#!/bin/bash
# Script converting between different certificate formats and also allowing to split PEM file containing multiple certs into separate PEM files
# https://github.com/misiektoja/forklift_x509_tools

# Put path to GNU sed & awk binaries below
awk="/opt/homebrew/bin/gawk"
sed="/opt/homebrew/opt/gnu-sed/libexec/gnubin/sed"

if [ $# -lt 2 ]; then
    echo "$0 <pem2der|der2pem|p12|split-pem> <file> [P12/PFX password]"
    exit 1
fi

mode=$1
sfile=$2
password=$3

filename=$(basename -- "$sfile")
extension="${filename##*.}"
extension=$(echo $extension|tr '[:lower:]' '[:upper:]')
filename="${filename%.*}"

if [ $mode = "pem2der" ]; then
    dfile=$(echo "$sfile" | $sed -r 's/(\.pem|\.crt|\.cer)/\.der/Ig')
	/usr/bin/openssl x509 -outform der -in "$sfile" -out "$dfile"
elif [ $mode = "der2pem" ]; then
    dfile=$(echo "$sfile" | $sed -r 's/(\.der|\.cer)/\.pem/Ig')
    /usr/bin/openssl x509 -inform der -in "$sfile" -out "$dfile"
elif [ $mode = "p12" ]; then
    if [ -z "$password" ]; then
        read -sp "Type P12 password: " password
        echo
    fi
    /usr/bin/openssl pkcs12 -in "$sfile" -clcerts -nokeys -nomacver -passin pass:"$password"| $sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$filename"_cert.pem
    /usr/bin/openssl pkcs12 -in "$sfile" -nodes -nocerts -nomacver -passin pass:"$password"| $sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' > "$filename"_pkey.pem
    /usr/bin/openssl pkcs12 -in "$sfile" -cacerts -nokeys -chain -nomacver -passin pass:"$password"| $sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$filename"_CA_cert.pem&&[ -s "$filename"_CA_cert.pem ] || rm -f "$filename"_CA_cert.pem
elif [ $mode = "split-pem" ]; then
    $sed -n '/-----BEGIN CERTIFICATE-----/{:start /-----END CERTIFICATE-----/!{N;b start};/.*/p}' "$sfile"|$awk -v var="$filename" 'BEGIN {counter=0;} /BEGIN CERT/{counter++} { print > var "_splitted_cert-" counter ".pem"}'
    $sed -n '/-----BEGIN PRIVATE KEY-----/{:start /-----END PRIVATE KEY-----/!{N;b start};/.*/p}' "$sfile" > "$filename"_splitted_pkey.pem&&[ -s "$filename"_splitted_pkey.pem ] || rm -f "$filename"_splitted_pkey.pem
else
    echo "Mode not supported"
    exit 1
fi

exit 0
