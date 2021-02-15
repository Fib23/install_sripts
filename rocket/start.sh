apt update && \
apt upgrade -y;
# Install mongo
apt-get install gnupg -y && \
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - && \
echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list && \
apt-get update && \
apt-get install -y mongodb-org;
#
apt-get update && apt-get install -y curl dirmngr && curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
apt-get install -y build-essential mongodb-org nodejs graphicsmagick && \
npm install -g inherits n && n 12.18.4;
#
curl -L https://releases.rocket.chat/latest/download -o /tmp/rocket.chat.tgz && \
tar -xzf /tmp/rocket.chat.tgz -C /tmp && \
cd /tmp/bundle/programs/server && npm install && \
mv /tmp/bundle /opt/Rocket.Chat;
#
useradd -M rocketchat && usermod -L rocketchat && \
chown -R rocketchat:rocketchat /opt/Rocket.Chat && \
cat << EOF | tee -a /lib/systemd/system/rocketchat.service
[Unit]
Description=The Rocket.Chat server
After=network.target remote-fs.target nss-lookup.target nginx.service mongod.service
[Service]
ExecStart=/usr/local/bin/node /opt/Rocket.Chat/main.js
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=rocketchat
User=rocketchat
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat?replicaSet=rs01 MONGO_OPLOG_URL=mongodb://localhost:27017/local?replicaSet=rs01 ROOT_URL=http://localhost:3000/ PORT=3000
[Install]
WantedBy=multi-user.target
EOF
;
sed -i "s/^#  engine:/  engine: wiredTiger/"  /etc/mongod.conf && \
sed -i "s/^#replication:/replication:\n  replSetName: rs01/" /etc/mongod.conf && \
systemctl enable mongod &&  systemctl start mongod && \
mongo --eval "printjson(rs.initiate())" && \
systemctl enable rocketchat &&  systemctl start rocketchat;