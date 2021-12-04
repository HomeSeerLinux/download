#!/bin/bash
# hsstop.sh - stop the HS application
# supports: systemd service shutdown

# import login credentials used to login to web server
# these are ignored if password not required
inifile=$(dirname $0)/Config/$(basename $0 .sh).ini
login=
test -r $inifile && . $inifile

# extract web server port from settings.ini
hsroot=$(dirname $0)  # where this script lives
webport=$(awk -F= '\
{
    gsub("\015", "") # remove CR character
    if ($1 == "gWebSvrPort") print $2
}
' $hsroot/Config/settings.ini)

# send application shutdown command
for i in $(seq 1 5)
do
    curl -f -s -o /dev/null ${login:+-u} $login -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data 'ConfirmShutdownhs=Yes' "http://localhost:$webport/LinuxTools" --compressed
    rc=$?
    test $rc -eq 0 && break
    sleep 2
done

killmain()
{
    test -n "$MAINPID" && kill -0 $MAINPID && kill $MAINPID
}

trap killmain EXIT

# if curl cmd unsuccessful, terminate main process
test $rc -ne 0 && killmain

# wait until all HomeSeer mono processes terminate, with timeout
maxwait=300
polltime=5
mono=$(which mono) || exit
for (( t=0; t<$maxwait; t+=$polltime ))
do
    pgrep -af $mono.'*'\(HSConsole\|HomeSeer\) || break
    sleep $polltime
done