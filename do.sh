#!/bin/sh

set -e

PATH="$HOME/.local/local/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:$PATH"

cd ~/rgb_txt/

RGBTXT=rgb.txt

LINES=$(wc -l "$RGBTXT" | awk '{print $1}')
LINE=$(bash -c "echo \$((\$RANDOM\$RANDOM\$RANDOM % $LINES))")
COLOR=$(head -n "$LINE" "$RGBTXT" | tail -n 1)

TMPDIR="$PWD"
TMPGIF=$(mktemp -p "$TMPDIR" out-XXXXXXXXX.gif)
TMPOUT=$(mktemp -p "$TMPDIR" out-XXXXXXXXX.txt)

convert -size 500x500 xc:"$COLOR" "$TMPGIF"

twurl set default rgb_txt
twurl -H upload.twitter.com -X POST "/1.1/media/upload.json" --file "$TMPGIF" --file-field media >"$TMPOUT"
MEDIAID=$(cat "$TMPOUT" | tr -d '"{}   ' | tr -s , '\n' | grep '^media_id:' | cut -d: -f2)
twurl /1.1/statuses/update.json -d "status=$COLOR" -d "media_ids=$MEDIAID" >/dev/null

rm -f "$TMPOUT"
rm -f "$TMPGIF"
