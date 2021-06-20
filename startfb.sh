#!/bin/sh

FB_VER="2.1"
FB_FLAVOUR="super"

FUNCTIONS="/usr/share/firebird${FB_VER}-common/functions.sh"
[ -e "$FUNCTIONS" ] || exit 0
. "$FUNCTIONS"

FBRunUser=firebird
PIDFILE="$RUN/fbserver.pid"
FB_OPTS="-start -forever -pidfile $PIDFILE"
NAME="Firebird $FB_VER server manager"

# Check the manager is there and is executable.
MANAGER=$FB/bin/fbmgr.bin
FBGUARD=$FB/bin/fbguard
FBSERVER=$FB/bin/fbserver
[ -x $FBGUARD ] || exit 0

# Check to see if super-server is enabled
ENABLE_SUPER_SERVER="no"    # disabled by default
[ -r "$DEFAULT" ] && . "$DEFAULT"

# workaround of splashy's #400598
# define RUNLEVEL to avoind unbound variable error
RUNLEVEL=${RUNLEVEL:-}

create_var_run_firebird
# remove stale pid file
rm -f $PIDFILE

$MANAGER $FB_OPTS

