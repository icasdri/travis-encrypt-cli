#!/bin/sh

# Copyright (c) 2017 icasdri
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e

if [ "$#" -ne 2 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    printf 'Usage: travis-encrypt.sh REPO VAR\n' 1>&2
    printf '    REPO   repository to encrypt for (in the form username/repo)\n' 1>&2
    printf '     VAR   input variable to encrypt (in the form NAME=value)\n' 1>&2
    exit 1
fi

repo="$1"
plaintext="$2"

if ! echo "$repo" | grep -q '/'; then
    printf "ERROR: repo '%s' is not of the form username/repo.\n" "$repo" 1>&2
    exit 2
fi

if ! echo "$plaintext" | head -c 20 | grep -q '='; then
    printf "WARNING: input variable '%s' does not appear to use the NAME=value form (equal sign not detected in first 20 characters).\n" "$plaintext" 1>&2
fi

if echo "$plaintext" | grep '[[:space:]]'; then
    printf "WARNING: input variable '%s' contains whitespace.\n" "$plaintext" 1>&2
fi

printf "Retrieving public key for repo '%s' ...\n" "$repo" 1>&2
keymaterial=$(curl -s "https://api.travis-ci.org/repos/${repo}/key" | sed 's/{"key":"\([^"]\+\)".*/\1/; s/\\n/\n/g;')

if [ "$(echo "$keymaterial" | head -c 1)" = '{' ]; then
    printf "INTERNAL ERROR: failed to parse out private key from json\n" 1>&2
    exit 3
fi

keyfilenamepre="${TMPDIR:-/tmp}"
keyfilename=$(mktemp "${keyfilenamepre%/}/travis-encrypt.XXXXXXXX")

printf "Writing key material to %s ...\n" "$keyfilename" 1>&2
echo "$keymaterial" > "$keyfilename"

printf "Performing encryption ...\n" 1>&2
echo "$plaintext" | openssl rsautl -encrypt -pubin -inkey "$keyfilename" | openssl base64 -e | tr -d '[:space:]'
printf '\n'

rm "$keyfilename"
