# forklift_x509_tools

Simple shell scripts allowing for displaying and conversion of X.509 certificate / private key files in Forklift via Quick Open.

## List of scripts

- **ssl_display_cert.sh**: script displaying details of DER/PEM/CRT/CER/P12/PFX/P7B certificate files
- **ssl_display_pkey.sh**: script displaying details of RSA/EC DER/PEM/P12/PFX private key files
- **ssl_display_csr.sh**: script displaying details of CSR files
- **ssl_convert_cert.sh**: script converting between different certificate formats and also allowing to split PEM file containing multiple certs into separate PEM files

## Requirements

The scripts require Binarynights [Forklift 4.x](https://binarynights.com) file manager, openssl binary and GNU version of sed+awk which can be installed via brew:

```
brew install gnu-sed gawk
```

The scripts can also be used as standalone shell scripts without Forklift. It should work under any macOS/Linux/Unix.

## Installation

Copy the scripts to the directory of choice, add executable rights:

```
chmod a+x ssl_display_cert.sh  ssl_display_csr.sh ssl_display_pkey.sh ssl_convert_cert.sh
```

## Configuration

Change sed and awk binary paths in every script in case they are different in your case.

Then create a new Forklift tool for every script via Commands -> Manage Tools and select 'Show output' option.

<p align="center">
   <img src="./assets/forklift_x509_tools_config.png" alt="forklift_x509_tools_config" width="70%"/>
</p>

Type the default password in case of encrypted files as Forklift does not allow to get input from the user (however if you use it as standalone script you can type it as command line argument or the script will ask for the password in case it is missing).

That's it, now if you press keyboard shortcut for Quick Open (Esc by default) you will have the option to handle your X.509 files directly from Forklift interface.

## License

This project is licensed under the GPLv3 - see the [LICENSE](LICENSE) file for details
