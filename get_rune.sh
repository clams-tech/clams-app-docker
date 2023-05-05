#!/bin/bash

set -e

NODE_ID=0
RUNE_TYPE="admin"
SESSION_ID=

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --id=*)
            NODE_ID="${i#*=}"
            shift
        ;;
        --type=*)
            RUNE_TYPE="${i#*=}"
            shift
        ;;
        --session-id=*)
            SESSION_ID="${i#*=}"
            shift
        ;;
        *)
        ;;
    esac
done

if [ -z "$SESSION_ID" ]; then
    echo "ERROR: SESSION_ID must be specified."
    exit 1
fi

RUNE_JSON=
if [ "$RUNE_TYPE" = admin ]; then
    RUNE_JSON=$(bash -c "./lightning-cli.sh --id=${NODE_ID} commando-rune restrictions='[[\"id=${SESSION_ID}\"], [\"rate=60\"]]'")
elif [ "$RUNE_TYPE" = read-only ]; then
    RUNE_JSON=$(bash -c "./lightning-cli.sh --id=${NODE_ID} commando-rune restrictions='[[\"id=$SESSION_ID\"], [\"method^list\",\"method^get\",\"method=summary\",\"method=waitanyinvoice\",\"method=waitinvoice\"],[\"method/listdatastore\"], [\"rate=60\"]]'")
elif [ "$RUNE_TYPE" = clams ]; then
    RUNE_JSON=$(bash -c "./lightning-cli.sh --id=${NODE_ID} commando-rune restrictions='[[\"id=$SESSION_ID\"], [\"method^list\",\"method^get\",\"method=summary\",\"method=pay\",\"method=keysend\",\"method=invoice\",\"method=waitanyinvoice\",\"method=waitinvoice\", \"method=signmessage\", \"method^bkpr-\"],[\"method/listdatastore\"], [\"rate=60\"]]'")
    
else
    echo "ERROR: invalid RUNE_TYPE."
    exit 1
fi

RUNE=$(echo "$RUNE_JSON" | jq -r '.rune')
echo "CLN-${NODE_ID} ${RUNE_TYPE} rune: ${RUNE}"