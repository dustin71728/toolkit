#!/bin/bash

USER="$(who| cut -d ' ' -f1)"
BIN_DIR=/home/"$USER"/bin
SWITCH_SH="$BIN_DIR"/touchpad_switcher.sh
mkdir -p "$BIN_DIR"

(
cat << 'EOF'
#!/bin/bash

# http://askubuntu.com/questions/533266/how-to-disable-notebooks-touchpad-on-usb-mouse-connect-and-slower-the-last

enabled=$1
touchpadId=$( xinput | grep -i "touchpad" | cut -f2 | cut -d '=' -f2 )

if $enabled; then
    xinput set-prop "$touchpadId" "Device Enabled" 1 | notify-send "The touchpad is now enabled." ""
else
    xinput set-prop "$touchpadId" "Device Enabled" 0 | notify-send "Disabling the touchpad..." ""    
fi
EOF
) > "$SWITCH_SH"

chmod +x "$SWITCH_SH"

(
cat <<EOF # no quoting limit string enable parameter subsitution.
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="mouse[0-9]", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/$USER/.Xauthority", ENV{ID_CLASS}="mouse", RUN+="$SWITCH_SH false"
    ACTION=="remove", SUBSYSTEM=="input", KERNEL=="mouse[0-9]", ENV{DISPLAY}=":0",ENV{XAUTHORITY}="/home/$USER/.Xauthority", ENV{ID_CLASS}="mouse", RUN+="$SWITCH_SH true"
EOF
) > /etc/udev/rules.d/10-mousetouchpad.rules

