#!/bin/bash
sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
sudo mkswap /var/swap.img
sudo swapon /var/swap.img
sudo echo "/var/swap.img none swap sw 0 0" | sudo tee --append /etc/fstab
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt autoremove -y
sudo apt-get install nano htop git -y
sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common -y
sudo apt-get install libboost-all-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo mkdir -p ~/repos/mogwai
sudo git clone https://github.com/mogwaicoin/mogwai.git ~/repos/mogwai
cd ~/repos/mogwai
sudo bash autogen.sh
sudo bash configure
sudo make
sudo make install
cd
sudo mkdir ~/mogwai
sudo mkdir ~/.mogwaicore
sudo cp ~/repos/mogwai/src/mogwaid ~/mogwai
sudo cp ~/repos/mogwai/src/mogwai-cli ~/mogwai
sudo strip ~/mogwai/*
sudo apt-get install -y pwgen
GEN_PASS=`pwgen -1 20 -n`
echo -e "#----\nrpcuser=mogwaiuser\nrpcpassword=${GEN_PASS}\nrpcallowip=127.0.0.1\n#----\nlisten=1\nserver=1\ndaemon=1\nmaxconnections=64" | sudo tee --append ~/.mogwaicore/mogwai.conf
./mogwai/mogwaid
masternodekey=$(./mogwai/mogwai-cli masternode genkey)
./mogwai/mogwai-cli stop
echo -e "masternode=1\nmasternodeprivkey=$masternodekey" >> /root/.mogwaicore/mogwai.conf
./mogwai/mogwaid
cd ~/.mogwaicore
sudo apt-get install -y git python-virtualenv
sudo git clone https://github.com/mogwaicoin/mogwai-sentinel.git sentinel
cd sentinel
export LC_ALL=C
sudo apt-get install -y virtualenv
virtualenv venv
venv/bin/pip install -r requirements.txt
echo "mogwai_conf=/root/.mogwaicore/mogwai.conf" >> ~/.mogwaicore/sentinel/sentinel.conf
crontab -l > tempcron
echo "* * * * * cd ~/.mogwaicore/sentinel && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log" >> tempcron
crontab tempcron
rm tempcron
cd
echo "Masternode private key: $masternodekey"
echo "Job completed successfully"