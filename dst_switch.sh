#!/bin/bash

# Variables
UHR_IP="192.168.50.161"
EMAIL="your@email.ch"  # Adjust
SENDER="sender@email.ch"  # Adjust
JQ=/usr/bin/jq
CURL=/usr/bin/curl

# Current date
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)

# Function: Calculate last Sunday in month
get_last_sunday() {
  local m=$1
  local last_day=31  # For March/October
  for d in $(seq $last_day -1 1); do
    if [ "$(date -d "$YEAR-$m-$d" +%u)" = 7 ]; then
      echo $d
      return
    fi
  done
}

# Check if today is switching day
DST=""
if [ "$MONTH" = "03" ]; then
  LAST_SUN=$(get_last_sunday 3)
  if [ "$DAY" != "$LAST_SUN" ]; then exit 0; fi
  DST="summer"
elif [ "$MONTH" = "10" ]; then
  LAST_SUN=$(get_last_sunday 10)
  if [ "$DAY" != "$LAST_SUN" ]; then exit 0; fi
  DST="standard"
else
  exit 0
fi

# Get current config
JSON=$($CURL -s "http://$UHR_IP/config?cmd=sta")
SSID_B64=$($JQ -r '.ssid' <<< "$JSON" | base64)
PW=$($JQ -r '.password' <<< "$JSON")
TZ=$($JQ -r '.timezone' <<< "$JSON")
LANG=$($JQ -r '.language' <<< "$JSON")

# New JSON
NEW_JSON='{"sta":{"ssid":"'"$SSID_B64"'","password":"'"$PW"'"},"timezone":'"$TZ"',"autoadjust":"21:00","daylightsavingtime":"'"$DST"'","language":"'"$LANG"'"}'

# Set config
$CURL -H "StaData: $NEW_JSON" "http://$UHR_IP/config?cmd=sta" > /dev/null

# Verify
sleep 5
NEW_DST=$($JQ -r '.daylightsavingtime' <<< "$($CURL -s "http://$UHR_IP/config?cmd=sta")")

# E-Mail
SUBJECT="DST switch: "
BODY="Switch to $DST time.\n"
if [ "$NEW_DST" = "$DST" ]; then
  SUBJECT+="Success"
  BODY+="Successfully switched."
else
  SUBJECT+="Failure"
  BODY+="Error: Currently $NEW_DST (expected $DST)."
fi

echo -e "To: $EMAIL\nFrom: $SENDER\nSubject: $SUBJECT\n\n$BODY" | ssmtp $EMAIL
