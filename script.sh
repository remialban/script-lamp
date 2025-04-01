#!/bin/bash

MARIADB_PASSWORD=azerty

apt-get update

apt-get install -y libapache2-mod-php
apt-get install -y mariadb-server
apt-get install -y php-pdo php-pdo-mysql
apt-get install -y git

systemctl enable --now apache2
systemctl enable --now mariadb

mariadb -e "SET PASSWORD FOR root@localhost = PASSWORD('$MARIADB_PASSWORD')"


a2enmod rewrite

APACHE_CONF_FILE=/etc/apache2/sites-available/000-default.conf
sed -i '/<\/VirtualHost>/d' $APACHE_CONF_FILE

echo -e "\t<Directory /var/www/html>" >> $APACHE_CONF_FILE
echo -e "\t\tAllowOverride All" >> $APACHE_CONF_FILE
echo -e "\t</Directory>" >> $APACHE_CONF_FILE
echo -e "\n</VirtualHost>" >> $APACHE_CONF_FILE


systemctl restart apache2


apt install phpmyadmin

CONNECTED_USER=$(who | tr -s " " | cut -d " " -f1)

chown -R $CONNECTED_USER:www-data /var/www/html
sudo usermod -aG www-data $CONNECTED_USER

chmod g+rxw /var/www/html
chmod g+s /var/www/html

PHP_VERSION=$(php --ini | grep etc | tail -n 1 | cut -d "/" -f4)

PHP_FILE=/etc/php/${PHP_VERSION}/apache2/php.ini

sed -i 's/display_errors =.*/display_errors=On/' "$PHP_FILE"

PHP_FILE_CONSOLE=/etc/php/${PHP_VERSION}/cli/php.ini

sed -i 's/display_errors =.*/display_errors=On/' "$PHP_FILE_CONSOLE"

systemctl restart apache2

snap install ponysay

PRENOM=$(getent passwd $CONNECTED_USER | cut -d ":" -f5 | cut -d " " -f1)

ponysay "L'installation est terminé ! Si vous avez des problèmes par la suite sur les droits des fichiers pour /var/www/html, relancer le script ! Appuyez sur q pour sortir du terminal ! Bon courage $PRENOM !" | less -R
echo "Installation terminé!"
