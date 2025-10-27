# DST Switch Script for WiFi Clock

* THE SCRIPT WON'T WORK AS LONG AS THE CLOCK GOES OFFLINE *

This Bash script automates the switching of Daylight Saving Time (DST) on a WiFi-enabled clock (e.g., Mondaine stop2go) via its web interface. It runs daily as a cronjob but only executes on the last Sunday of March (to summer time) and October (to standard time). It verifies the change and sends an email notification about success or failure using ssmtp.

## Features
- Automatically detects the correct DST switching dates each year.
- Fetches current config from the clock's API.
- Updates only the DST setting while preserving other configs.
- Verifies the update after 5 seconds.
- Sends email reports.

## Requirements
- Ubuntu (headless) or similar Linux environment.
- Installed packages: `jq`, `ssmtp`, `curl`.
- Configure ssmtp in `/etc/ssmtp/ssmtp.conf` for email sending.
- Clock accessible at IP `192.168.1.123` (adjust in script if needed).

## Installation
1. Create the script file: `/usr/local/bin/dst_switch.sh`.
2. Make it executable: `chmod +x /usr/local/bin/dst_switch.sh`.
3. Adjust variables in the script: `UHR_IP`, `EMAIL`, `SENDER`.
4. Add cronjob: `crontab -e` and insert `0 3 * * * /usr/local/bin/dst_switch.sh`.
