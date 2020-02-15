#! bin/bash
# Wordpress Installation

cwd=$PWD
dir_wpress_pkg=~/wpress

sudo apt install apache2 -y
sudo apt install php -y
sudo apt install php-curl -y
sudo apt install php-zip -y
sudo apt install php-mbstring -y
sudo apt install php-mysql -y
sudo apt install php-xml -y
sudo apt install mariadb-server -y
sudo apt install yarn -y
sudo apt install unzip -y
sudo apt install zip -y

# https://github.com/nodesource/distributions
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs

mkdir -p $dir_wpress_pkg
cd $dir_wpress_pkg

wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz


