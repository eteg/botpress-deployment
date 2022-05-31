#!/bin/bash

if [ "$#" -ne 4 ]
then
        echo "Usage: ./install.sh [major] [minor] [patch] [bd_password]"
        exit
fi

#Create a separate folder for Botpress installation
mkdir ~/botpress
cd ~/botpress

version=v$1_$2_$3

#Downloading latest Botpress version
wget https://s3.amazonaws.com/botpress-binaries/botpress-$version-linux-x64.zip

#Install unzip tool, unzip the package and remove it
sudo apt install unzip
unzip botpress-$version-linux-x64.zip
rm botpress-$version-linux-x64.zip

#Copies the script to create users
cp ~/botpress-deployment/createUser.sh .
chmod +x createUser.sh

#Install Postgres
sudo apt install postgresql

#Copy the custom smooch (Sunshine Conversations) module
cp ~/botpress-deployment/channel-smooch.tgz modules/channel-smooch.tgz

#Configure the systemd service files
sed -i "s/\[USER\]/$USER/g" ~/botpress-deployment/botpress.sh
sed -i "s/\[USER\]/$USER/g" ~/botpress-deployment/botpress.service
sudo cp ~/botpress-deployment/botpress.sh /usr/bin/botpress.sh
sudo cp ~/botpress-deployment/botpress.service /etc/systemd/system/botpress.service

#Create Postgres user and database
sudo su - postgres -c "psql -c \"CREATE USER $USER WITH PASSWORD '$4';\""
sudo su - postgres -c "psql -c \"CREATE DATABASE botpress WITH OWNER = '$USER';\""

#Configure environment variables for Botpress
sed -i "s/\[USER\]/$USER/g" ~/botpress-deployment/.env
sed -i "s/\[PASSWORD\]/$4/g" ~/botpress-deployment/.env
sudo cp ~/botpress-deployment/.env .

#Starts, enable and check status of Botpress systemd service
sudo systemctl daemon-reload
sudo systemctl start botpress
sudo systemctl status botpress
sudo systemctl enable botpress

cd ~/botpress-deployment