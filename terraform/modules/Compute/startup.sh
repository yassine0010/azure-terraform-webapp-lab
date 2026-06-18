#!/bin/bash
apt-get update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs git
npm install -g pm2

cat > /etc/environment << 'ENVFILE'
DB_HOST=${db_host}
DB_PORT=3306
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
DB_SSL=false
PORT=8080
ENVFILE

export DB_HOST="${db_host}"
export DB_PORT="3306"
export DB_USER="${db_user}"
export DB_PASSWORD="${db_password}"
export DB_NAME="${db_name}"
export DB_SSL="false"
export PORT="8080"
rm -rf /app
git clone https://github.com/yassine0010/azure-terraform-webapp-lab.git /app
cd /app
npm install
pm2 start index.js --name "myapp"
pm2 startup systemd -u root --hp /root
pm2 save