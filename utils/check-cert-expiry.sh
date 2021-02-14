#!/usr/bin/env bash

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

check_it() {
    DATE=`echo |
        openssl s_client -servername $1 -connect $1:443 2>/dev/null |
        openssl x509 -noout -dates |
        grep notAfter |
        cut -d'=' -f2-`
    PARSED=$(date -d "$DATE" '+%s')
    NOW=$(date '+%s')
    ELAPSED=$(((PARSED-NOW)/(60*60*24)))
    echo $ELAPSED days: $1
}

check_it "$1"
