#!/bin/bash
if [ $# -eq 0 ]; then echo "Select monitor id as argument"
else
	remouse --orientation left --mode fill --monitor $1 --passwd XXXXXX --evdev &
fi
