#! /bin/sh
set -euo pipefail

CONVERTED_KEY=$(printf -- "$1" | openssl pkcs8 -inform PEM -outform PEM -topk8 -nocrypt -v1 PBE-SHA1-3DES)
echo '{"converted":null }' | jq -rc ".converted = \"$CONVERTED_KEY\n\""
