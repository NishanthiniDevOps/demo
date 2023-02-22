#!/bin/bash
apt update
apt install nginx git postgresql -y
apt install php-fpm php-pgsql -y
git clone https://github.com/NishanthiniDevOps/demo.git
mkdir /var/www/democrance
cp demo/nginx/democrance /etc/nginx/sites-available/democrance
ln -s /etc/nginx/sites-available/democrance /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default
systemctl reload nginx
cp demo/index.php /var/www/democrance
cp demo/response.php /var/www/democrance
cp demo/connection.php /var/www/democrance
PGPASSWORD=${db_pass} psql -h ${host} -d ${db} -U ${db_username} -p 5432 -a -q -f demo/employee.sql
openssl req -x509 -newkey rsa:4096 -nodes -keyout /etc/nginx/ssl/democrance.key -out /etc/nginx/ssl/democrance.crt  -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.demo.com"
