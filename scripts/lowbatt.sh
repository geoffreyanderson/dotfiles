#!/usr/bin/env bash
# Originally snagged from https://bbs.archlinux.org/viewtopic.php?pid=1271322#p1271322
# To get full use of this, you'll need libnotify and to setup a crontab entry like:
#    */5 * * * * /path/to/dotfiles/scripts/lowbatt.sh
# Or symlink the systemd .service and .timer files and set those up:
#    $ sudo ln -s /path/to/dotfiles/scripts/lowbatt.service /etc/systemd/system/lowbatt.service
#    $ sudo ln -s /path/to/dotfiles/scripts/lowbatt.timer /etc/systemd/system/lowbatt.timer
#    $ sudo systemctl start lowbatt.timer
#    $ sudo systemctl enable lowbatt.timer

# low battery in %
LOW_BATTERY="15"
# critical battery in % (execute action)
CRITICAL_BATTERY="3"
# action
ACTION="/usr/bin/pm-suspend"
# display icon
ICON="/usr/share/icons/gnome/32x32/status/battery-low.png"
# path to battery /sys
BATTERY_PATH="/sys/class/power_supply/BAT0/"


if [[ -e "$BATTERY_PATH" ]]; then
    BATTERY_ON="$(cat "${BATTERY_PATH}/status")"

    if [[ "$BATTERY_ON" == "Discharging" ]]; then
        CURRENT_BATTERY="$(cat "${BATTERY_PATH}/capacity")"

        if (( "$CURRENT_BATTERY" < "$CRITICAL_BATTERY" )); then
            $($ACTION)

        elif (( "$CURRENT_BATTERY" < "$LOW_BATTERY" )); then
            notify-send -i "$ICON"  "Battery IS low - ${CURRENT_BATTERY}%."
        fi
    fi
fi
