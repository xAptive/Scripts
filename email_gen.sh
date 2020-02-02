#!/bin/bash

# This script creates deterministic yet unpredictable email extensions for 
# services that support it, such as gmail and protonmail.  Using these
# extensions allows you to hide your email address on services from attackers
# who know your email address on other services.
#
# Example Usage:
#
# > ./email_gen Twitter
# Twitter : myname+c90e4a29@pm.me
#
# > ./email_gen Facebook
# Facebook : myname+bfba510b@pm.me

EMAIL_ID=myname
EMAIL_DOMAIN=pm.me
SECRET_SEED=df931e142e0a4e75b592d7fc7e638a2054b3a00580d3871e74263709c5dc0256
STR_SIZE=8
LOG_FILE=~/.local/share/email_extensions.txt
# Print usage and quit
usage() { echo "Usage: $0 <service_name>" 1>&2; exit 1; }

# Verify a service name was provided
if ((${#1} <= 0)); then
    usage
fi

# Convert service to upper case so that "Twitter" and "twitter" don't produce difference results
UCASE_SERVICE=$(echo $1 | awk '{ print toupper($0) }')

# Generate postfix value
POSTFIX=$(echo $SECRET_SEED$UCASE_SERVICE | sha256sum | head -c $STR_SIZE)

# Create resulting email address
EMAIL_RESULT="$EMAIL_ID+$POSTFIX@$EMAIL_DOMAIN"

# Copy the email address to the clipboard
echo $EMAIL_RESULT | xclip -selection clipboard

# Display email address for the user and log it
echo  "$1 : $EMAIL_RESULT" | tee -a $LOG_FILE

# Filter out duplicates in the log
TMP_FILE=$(mktemp)
sort -u -t':' -k2 $LOG_FILE > $TMP_FILE
mv $TMP_FILE $LOG_FILE
