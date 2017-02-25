#!/bin/bash

# http://askubuntu.com/questions/533266/how-to-disable-notebooks-touchpad-on-usb-mouse-connect-and-slower-the-last

enabled=$1
touchpadId=$( xinput | grep -i "touchpad" | cut -f2 | cut -d '=' -f2 )

if $enabled; then
    xinput set-prop "$touchpadId" "Device Enabled" 1 | notify-send "The touchpad is now enabled." ""
else
    xinput set-prop "$touchpadId" "Device Enabled" 0 | notify-send "Disabling the touchpad..." ""    
fi