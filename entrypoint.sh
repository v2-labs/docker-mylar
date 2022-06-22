#!/bin/sh

#
# Display settings on standard out.
#

USER="mylar"

echo "Mylar settings"
echo "=============="
echo
echo "  User:    ${USER}"
echo "  UID:     ${MYLAR_UID:=666}"
echo "  GID:     ${MYLAR_GID:=666}"
echo "  CHMOD:   ${MYLAR_CHMOD:=false}"
echo "  DEBUG:   ${DEBUG_LOG:=--quiet}"
echo
echo "  Config:  ${CONFIG:=/etc/mylar/config.ini}"
echo

#
# Change UID / GID of Mylar user.
#

printf "Updating UID / GID if needed... "
[[ $(id -u ${USER}) == ${MYLAR_UID} ]] || usermod  -o -u ${MYLAR_UID} ${USER}
[[ $(id -g ${USER}) == ${MYLAR_GID} ]] || groupmod -o -g ${MYLAR_GID} ${USER}
echo "[DONE]"

#
# Set directory permissions.
#
printf "Set permissions... "
touch ${CONFIG}
chown -R ${MYLAR_UID}:${MYLAR_GID} \
      /home/mylar /opt/mylar > /dev/null 2>&1
[[ "${MYLAR_CHMOD}" == "false" ]] || \
      chown -R ${MYLAR_UID}:${MYLAR_GID} \
      /mnt/mylar/comics   /mnt/mylar/downloads \
      /mnt/mylar/torrents /etc/mylar \
      > /dev/null 2>&1
echo "[DONE]"

#
# Because Mylar runs in a container we've to make sure we've a proper
# listener on 0.0.0.0. We also have to deal with the port which by default is
# 8090 but can be changed by the user.
#

printf "Get listener port... "
PORT=$(sed -n '/^port *=/{s/port *= *//p;q}' ${CONFIG})
LISTENER="--port=${PORT:=8090}"
echo "[${PORT}]"

#
# Finally, start Mylar.
#

echo "Starting Mylar..."
exec su -p ${USER} -c "python -OO /opt/mylar/Mylar.py --nolaunch ${DEBUG_LOG} --datadir=$(dirname ${CONFIG}) ${LISTENER} --config=${CONFIG}"
