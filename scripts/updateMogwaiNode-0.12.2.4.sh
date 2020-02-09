#!/bin/bash

CONFIG_FILE='mogwai.conf'
CONFIGFOLDER='/root/.mogwaicore'
COIN_DAEMON='/root/mogwai/mogwaicore-0.12.2/bin/mogwaid'
COIN_CLI='/root/mogwai/mogwaicore-0.12.2/bin/mogwai-cli'
COIN_DAEMON2='mogwaid'
COIN_CLI2='mogwai-cli'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='https://github.com/mogwaicoin/mogwai/releases/download/v0.12.2.5/mogwaicore-0.12.2.5-linux64.tar.gz'    
COIN_ZIP='/root//mogwai/mogwaicore-0.12.2.5-linux64.tar.gz'
SENTINEL_REPO='https://github.com/mogwaicoin/mogwai-sentinel.git'
COIN_NAME='MOGWAI'
COIN_PORT=17777
RPC_PORT=17710

NODEIP=$(curl -s4 api.ipify.org)


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function download_node() {
  echo -e "Preparing to download ${GREEN}$COIN_NAME${NC}."
  wget -q $COIN_TGZ
  compile_error
  tar xvzf $COIN_ZIP
  chmod +x $COIN_DAEMON $COIN_CLI
  chown root: $COIN_DAEMON $COIN_CLI
  cp $COIN_DAEMON $COIN_PATH
  cp $COIN_CLI $COIN_PATH
  clear
}

function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON2 -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_CLI2 -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}

function important_information() {
 echo -e "================================================================================================================================"
 echo -e "$COIN_NAME Node is up and running."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "Please check ${RED}$COIN_NAME${NC} daemon is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "================================================================================================================================"
}

##### Main #####
clear

download_node
important_information
configure_systemd
