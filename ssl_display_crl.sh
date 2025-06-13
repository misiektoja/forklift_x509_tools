#!/bin/bash
# Script displaying details of CRL files
# We use an external text editor due to ForkLift's output length limitations
# https://github.com/misiektoja/forklift_x509_tools

text_editor="Sublime Text"

if [ $# -lt 1 ]; then
    echo "$0 <PEM/DER/CRL"
    exit 1
fi

sfile=$1

uname_str=$(uname)

if [[ "$uname_str" == "Darwin" ]]; then
    # macOS - BSD mktemp
	tmp_file=$(mktemp -t ssl_display_crl_output)
	mv "$tmp_file" "${tmp_file}.txt"
	tmp_file="${tmp_file}.txt"
else
    # Linux - GNU mktemp
    tmp_file=$(mktemp /tmp/ssl_display_crl_output.XXXXXX.txt)
fi

filename=$(basename -- "$sfile")
extension="${filename##*.}"
extension=$(echo $extension|tr '[:lower:]' '[:upper:]')
filename="${filename%.*}"
is_pem=$(file -b "$sfile"|grep -E -i "pem|ascii")

if [[ ( $extension = "PEM" ) || ( $extension == "CRL" && -n "$is_pem" ) ]]; then
	/usr/bin/openssl crl -text -inform pem -noout -in "$sfile" > "$tmp_file"
	open -a "$text_editor" "$tmp_file"
elif [[ ( $extension = "DER" ) || ( $extension == "CRL" && -z "$is_pem" ) ]]; then
    /usr/bin/openssl crl -text -inform der -noout -in "$sfile" > "$tmp_file"
    open -a "$text_editor" "$tmp_file"
else
	echo "File format not supported"
	exit 1
fi

exit 0
