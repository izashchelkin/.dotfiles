if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  exec dbus-run-session -- "$0" "$@"
fi

xrandr --output 'HDMI-0' --mode 3440x1440 --rate 100 --output 'DP-2' --off ||\
xrandr --output 'HDMI-0' --mode 2560x1440 --output 'DP-2' --off

dunst &
redshift -l 49:8 &

while true; do 
	umount ~/wm-debugfs
	if ! ~/wm 2&> ~/nylalog; then
		break
	fi
done

