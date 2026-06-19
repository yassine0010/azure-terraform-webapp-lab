#!/bin/bash
apt-get update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs git
npm install -g pm2

mkdir -p /app
# Combined CA bundle: covers both old (SHA-1) and current (SHA-256) Azure MySQL roots
curl -sS https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem -o /app/azure-mysql-ca-bundle.pem
curl -sS https://dl.cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem >> /app/azure-mysql-ca-bundle.pem

cat > /etc/environment << 'ENVFILE'
DB_HOST=${db_host}
DB_PORT=3306
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
DB_SSL=true
PORT=8080
ENVFILE
export DB_HOST="${db_host}"
export DB_PORT="3306"
export DB_USER="${db_user}"
export DB_PASSWORD="${db_password}"
export DB_NAME="${db_name}"
export DB_SSL="true"
export PORT="8080"

rm -rf /app/repo
git clone https://github.com/yassine0010/azure-terraform-webapp-lab.git /app/repo
cp /app/azure-mysql-ca-bundle.pem /app/repo/
cd /app/repo
npm install
pm2 start index.js --name "myapp"
pm2 startup systemd -u root --hp /root
pm2 save