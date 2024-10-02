#!/bin/bash
DATABASE_PASS='admin123'
ADMIN_USER='admin'
ADMIN_PASS='admin123'

# Update packages
sudo yum update -y

# Install necessary packages
sudo yum install git zip unzip -y
sudo dnf install mariadb105-server -y

# Start & enable MariaDB service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Clone the project from GitHub
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git

# Set MySQL root password and secure the installation
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DATABASE_PASS'"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Create the 'accounts' database and set up user privileges
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO '$ADMIN_USER'@'localhost' IDENTIFIED BY '$ADMIN_PASS'"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO '$ADMIN_USER'@'%' IDENTIFIED BY '$ADMIN_PASS'"
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart MariaDB to apply changes
sudo systemctl restart mariadb

# Firewall setup (correct syntax for firewall-cmd)
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent 
sudo firewall-cmd --reload

# Restart MariaDB after firewall setup (optional)
sudo systemctl restart mariadb
