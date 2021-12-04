#!/bin/bash

# send the `shutdown` command followed by ENTER keystroke to
# tmux `homeseer` session using a custom socket `/tmp/homeseer`
tmux -S /opt/HomeSeer/homeseer.tmux send-keys -t homeseer Enter
tmux -S /opt/HomeSeer/homeseer.tmux send-keys -t homeseer -l shutdown
tmux -S /opt/HomeSeer/homeseer.tmux send-keys -t homeseer Enter


