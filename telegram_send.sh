#!/usr/bin/env bash
set -euo pipefail

BOT_TOKEN="8247523135:AAFnukDL2GV4zoS-Wk1juiya-AdF0s3UvJU"
CHAT_ID="-1003866396190"
THREAD_ID="1944"
API="https://api.telegram.org/bot${BOT_TOKEN}"

usage() {
    echo "Usage:"
    echo "  $0 [--chat CHAT_ID] [--thread THREAD_ID] text \"message\""
    echo "  $0 [--chat CHAT_ID] [--thread THREAD_ID] file path/to/file [\"caption\"]"
    echo "  $0 [--chat CHAT_ID] [--thread THREAD_ID] photo path/to/image [\"caption\"]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --chat) CHAT_ID="$2"; shift 2 ;;
        --thread) THREAD_ID="$2"; shift 2 ;;
        *) break ;;
    esac
done

[ $# -lt 2 ] && usage

TYPE="$1"
shift

case "$TYPE" in
    text)
        curl -s -X POST "${API}/sendMessage" \
            -d chat_id="${CHAT_ID}" \
            -d message_thread_id="${THREAD_ID}" \
            -d text="📬 $1" \
            -d parse_mode="Markdown" > /dev/null
        echo "Message sent."
        ;;
    file)
        FILE="$1"
        CAPTION="${2:+📬 $2}"
        [ ! -f "$FILE" ] && echo "File not found: $FILE" && exit 1
        FILE_SIZE=$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE" 2>/dev/null || echo 0)
        if [ "$FILE_SIZE" -gt 52428800 ]; then
            echo "ERROR: File too large ($(( FILE_SIZE / 1048576 ))MB > 50MB)." >&2
            exit 1
        fi
        RESPONSE=$(curl -s -X POST "${API}/sendDocument" \
            -F chat_id="${CHAT_ID}" \
            -F message_thread_id="${THREAD_ID}" \
            -F document=@"$FILE" \
            ${CAPTION:+-F caption="$CAPTION"})
        if echo "$RESPONSE" | grep -q '"ok":true'; then
            echo "File sent: $FILE"
        else
            echo "ERROR sending file: $RESPONSE" >&2
            exit 1
        fi
        ;;
    photo)
        FILE="$1"
        CAPTION="${2:+📬 $2}"
        [ ! -f "$FILE" ] && echo "File not found: $FILE" && exit 1
        RESPONSE=$(curl -s -X POST "${API}/sendPhoto" \
            -F chat_id="${CHAT_ID}" \
            -F message_thread_id="${THREAD_ID}" \
            -F photo=@"$FILE" \
            ${CAPTION:+-F caption="$CAPTION"})
        if echo "$RESPONSE" | grep -q '"ok":true'; then
            echo "Photo sent: $FILE"
        else
            echo "ERROR sending photo: $RESPONSE" >&2
            exit 1
        fi
        ;;
    *)
        usage
        ;;
esac
