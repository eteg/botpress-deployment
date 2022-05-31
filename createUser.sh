#!/bin/bash

if [ "$#" -ne 1 ]
then
        echo "Usage: ./createUser.sh [email]"
        exit
fi
if ! command -v psql &> /dev/null
then
        echo "psql command not found. Please install postgres"
        exit
fi
if [ ! -f bp ]
then
        echo "This script must be run from inside Botpress root folder"
        exit
fi
SQL=$(printf "INSERT INTO strategy_default(email, password, salt, strategy, attributes) VALUES ('%s', '634b44198396046c654a0caa96a3b8eb4c14e55408fa55bfaad723580254d672a1c80bba7f3e7c464794434a6d9586c19a45398012c4410c0bc0c9647852b965', '477978f513f4e819', 'default', '{\"unsuccessful_logins\":0,\"locked_out\":false}');" $1)
psql -d botpress -c "$SQL"
echo "User created on database using default password \"...\". Change your password after the login. "
sed -i "s/\"superAdmins\": \[/\"superAdmins\": \[\n    {\n      \"email\": \"$1\",\n      \"strategy\": \"default\"\n    },/g" data/global/botpress.config.json
echo "User added to Botpress files"
sudo systemctl restart botpress
echo "Botpress service restarted"