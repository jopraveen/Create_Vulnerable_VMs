#!/bin/bash
echo "[+] Building our first vulnerable VM"
echo "[+] Machine name: Twenty22"
echo "[+] Run this script as root user"
echo "[+] Getting update"
# apt-get update

echo "[+] Installing utilities"
apt install -y net-tools open-vm-tools

echo "[+] Installing requirements"
apt install -y python3 python3-pip
apt install -y python3-flask
apt install -y apache2 
apt install -y libapache2-mod-wsgi 
apt install -y python-dev libapache2-mod-wsgi-py3
pip3 install flask
pip3 install virtualenv

echo "[+] Firewall rules"
sudo ufw allow 'Apache'
sudo ufw allow ssh

echo "[+] Creating directories & Copying files"
mkdir /var/www/FlaskApp
mkdir /var/www/FlaskApp/FlaskApp
cp -r /vagrant_data/flask_app/* /var/www/FlaskApp/FlaskApp/
cp /vagrant_data/flaskapp.wsgi /var/www/FlaskApp/

echo "[+] Setting up hostname"
hostnamectl set-hostname twenty22
cat <<EOF > /etc/hosts
127.0.0.1 localhost
127.0.0.1 twenty22.box

10.10.10.101 twenty22.box
EOF

echo "[+] Creating virtual environment"
virtualenv /var/www/FlaskApp/FlaskApp/venv
chmod +x /var/www/FlaskApp/FlaskApp/venv/bin/activate
source /var/www/FlaskApp/FlaskApp/venv/bin/activate
pip3 install Flask
deactivate

echo "[+] Creating config file for our flask app"
cat <<EOF > /etc/apache2/sites-available/FlaskApp.conf
<VirtualHost *:80>
		ServerName 10.10.10.101
		ServerAdmin admin@mywebsite.com
		WSGIScriptAlias / /var/www/FlaskApp/flaskapp.wsgi
		<Directory /var/www/FlaskApp/FlaskApp/>
			Order allow,deny
			Allow from all
		</Directory>
		Alias /static /var/www/FlaskApp/FlaskApp/static
		<Directory /var/www/FlaskApp/FlaskApp/static/>
			Order allow,deny
			Allow from all
		</Directory>
		ErrorLog ${APACHE_LOG_DIR}/error.log
		LogLevel warn
		CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

echo "[+] Starting the server"
sudo a2ensite FlaskApp
sudo service apache2 restart    
systemctl reload apache2

echo "[+] Creating users if the don't exists"
id -u pwn &>/dev/null || useradd -m pwn

echo "[+] Setting up passwords"
echo "pwn:w3lc0m379pWn&p41n" | chpasswd
echo "root:1th1nkN0new1llCracKth1sPasswd" | chpasswd

echo "[+] Dropping flags and changing permissons"
echo "d1210c65fabb7e2caf702b2a6a12e935" > /home/pwn/user.txt
echo "3641d6c08a482c1fa7740148e427ea6c" > /root/root.txt
chmod 0600 /home/pwn/user.txt
chown pwn:pwn /home/pwn/user.txt

echo "[+] Hiding user password in todo.txt"
cat <<EOF > /home/pwn/todo.txt
[+] Create FlaskApp
[+] Deploy it
[+] Start the CTF
[+] Manage it
[+] End the CTF
[+] Publish Scoreboard
[x] Change your password

Your current password is : w3lc0m379pWn&p41n
EOF
chmod 644 /home/pwn/todo.txt

echo "[+] Modifying gcc binary"
chmod u+s /usr/bin/gcc

echo "[+] Adding pwn in sudoers file and making him to run gcc as nopasswd"
echo "pwn ALL=(ALL) NOPASSWD: /usr/bin/gcc" >> /etc/sudoers

echo "[+] Symlinking bash history files"
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/pwn/.bash_history

echo "[+] Unmounting data directory"
sudo unmount /vagrant_data
