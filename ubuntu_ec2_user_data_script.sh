#!/bin/bash

# yum update -y
# yum install -y httpd.x86_64
# systemctl start httpd.service
# systemctl enable httpd.service
apt-get update
apt-get install -y apache2 stress
systemctl enable apache2
systemctl stop apache2
sleep 60
# echo "Hello World from $(hostname -f)" > /var/www/html/index.html
exec 1>sample.html
exec 2>&1
echo '<!doctype html>'
echo '<html lang="en">'
echo '  <head>'
echo '      <meta charset="utf-8">'
echo '      <title>Your Apache Webserver Worked</title>'
echo '  </head>'
echo '  <body>'
echo '      <h3>Hello, Narayanan from <font color="blue">HOSTNAME</font></h3>'
echo '  </body>'
echo '</html>'
sed -i "s/HOSTNAME/$(hostname -f)/" sample.html
mv sample.html /var/www/html/index.html
systemctl start apache2
systemctl enable apache2
