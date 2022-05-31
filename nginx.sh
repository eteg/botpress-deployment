#!/bin/bash

if [ "$#" -ne 2 -a "$#" -ne 3 ]
then
    	echo "Usage:"
		echo "./nginx.sh [http] [IP|DOMAIN]"
		echo "./nginx.sh [https] [DOMAIN] [CERT_EMAIL]"
        exit
fi

if [ "$#" -ne 3 -a "$1" == "https" ]
then
    	echo "Usage: ./nginx.sh [https] [DOMAIN] [CERT_EMAIL]"
        exit
fi

SERVER_NAME=$2
#Install NGINX
sudo apt install nginx

#Default nginx conf backup
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default-$(date +"%m-%d-%Y")

if [ $1 == "http" ]
then
	sed -i "s/\[SERVER_NAME\]/$SERVER_NAME/g" default-http

	#Edit nginx configuration
	sudo cp default-http /etc/nginx/sites-available/default
elif [ $1 == "https" ]
then
	#Edit nginx configuration for SSL generation
	sed -i "s/\[SERVER_NAME\]/$SERVER_NAME/g" default-http
	sudo cp default-http /etc/nginx/sites-available/default

	#Install Certbot to generate SSL certificate
	sudo apt-get install certbot python3-certbot-nginx
	sudo certbot --nginx --non-interactive -d $SERVER_NAME -m $3 --agree-tos

	#Replace Certbot default config to allow aditional security features
	sudo cp /etc/letsencrypt/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx-$(date +"%m-%d-%Y").conf
	sudo cp options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf

	#Put the final nginx config
	sed -i "s/\[DOMAIN\]/$SERVER_NAME/g" default-https
	sudo cp default-https /etc/nginx/sites-available/default
else
	echo "First parameter should be \"http\" or \"https\""
	exit
fi

#Restart and verify nginx services
sudo systemctl restart nginx
sudo systemctl status nginx