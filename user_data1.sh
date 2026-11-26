#!/bin/bash

apt update -y
apt install apache2 -y

systemctl start apache2
systemctl enable apache2

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Rinku User Dashboard</title>
</head>
<body>
    <h1>Welcome to Rinku's Application</h1>
    <h2>Running on EC2 Instance 1</h2>
    <p>Application Status: Healthy</p>
    <p>Server: Public EC2</p>
</body>
</html>
EOF