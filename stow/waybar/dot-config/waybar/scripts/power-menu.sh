#!/bin/bash

choice=$(printf "⏾ Sleep\n⭘ Shutdown\n↻ Reboot" | wofi --dmenu --prompt "Power")

case "$choice" in
  " Sleep")
    systemctl suspend
    ;;
  " Shutdown")
    systemctl poweroff
    ;;
  " Reboot")
    systemctl reboot
    ;;
esac
