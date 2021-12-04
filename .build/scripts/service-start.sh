#!/bin/bash

# start homeseer inside a tmux session named `homeseer` using a custom socket `/tmp/homeseer`
tmux -S /opt/HomeSeer/homeseer.tmux \
     new-session \
     -s homeseer \
     -d \
     /usr/bin/mono /opt/HomeSeer/HSConsole.exe --log

# change custom socket `/tmp/homeseer` permission for other users to access
chmod 777 /opt/HomeSeer/homeseer.tmux
