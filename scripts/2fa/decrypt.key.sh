#!/bin/bash

# Note: I am not the original author of this script
# All credit goes to: https://www.cyberciti.biz/faq/use-oathtool-linux-command-line-for-2-step-verification-2fa/
# The following is my modified version to have it running for macOS

# Purpose: Display 2FA code on screen
# Author: Vivek Gite {https://www.cyberciti.biz/} under GPL v 2.x or above
# --------------------------------------------------------------------------
# Path to gpg2 binary
_gpg2="/usr/local/MacGPG2/bin/gpg2"
_oathtool="/usr/local/bin/oathtool"

## run: gpg --list-secret-keys --keyid-format LONG to get uid and kid ##
# GnuPG user id 
uid=""

# GnuPG key id 
kid=""

# Directory 
dir="$HOME/.2fa"

# Build CLI arg
s="$1"
k="${dir}/${s}/.key"
kg="${k}.gpg"

# failsafe stuff
[ "$1" == "" ] && { echo "Usage: $0 service"; exit 1; }
[ ! -f "$kg" ] && { echo "Error: Encrypted file \"$kg\" not found."; exit 2; }

# Get totp secret for given service
totp=$($_gpg2 --quiet -u "${kid}" -r "${uid}" --decrypt "$kg")

# Generate 2FA totp code and display on screen
echo "Your code for $s is ..."
code=$($_oathtool -b --totp "$totp")
## Copy to clipboard too ##
type -a pbcopy &>/dev/null
[ $? -eq 0 ] && { echo $code | pbcopy; echo "*** Code copied to clipboard too ***"; }
echo "$code"

# Make sure we don't have .key file in plain text format ever #
[ ! -f "$k" ] && exit 0
[ -f "$k" ] && { echo "Warning - Plain text key file \"$k\" found."; exit 3; }