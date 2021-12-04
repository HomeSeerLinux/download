#!/bin/bash

# attach to tmux `homeseer` session using a custom socket `/tmp/homeseer`
tmux -S /opt/HomeSeer/homeseer.tmux attach-session -t homeseer
