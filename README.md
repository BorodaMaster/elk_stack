# Configure ELK Monitoring

## 0. Configure network interface

`vim /etc/netplan/02-netcfg.yaml`

```yaml
network:
  version: 2
  ethernets:
    eth1:
      addresses:
        - 192.168.57.HOST/24
      nameservers:
          addresses: [8.8.8.8]
```

`CHECK:`

```bash
nc -vz example.com 22 / 80 / 5044 / 5061 / 9200
```

`INFO:` [Help Ubuntu.com](https://help.ubuntu.com/lts/serverguide/network-configuration.html)

## 1. Install JAVA

```bash
apt install -y openjdk-8-jdk openjdk-8-jre
```

`CHECK:`

```bash
java -version && javac -version
```

## 2. NGINX

### - Install Nginx service

```bash
apt install nginx
echo "kibanaadmin:`openssl passwd -apr1`" | tee -a /etc/nginx/htpasswd.users
```

### Change configuration file(s)

`vim /etc/nginx/sites-available/example.com`

[Open file example.com](./nginx/example.com)

### Create symlink

```bash
ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/example.com
```

`CHECK:`

```bash
nginx -t
```

### - Restart Nginx service

```bash
systemctl restart nginx
```

## 3. Elasticsearch

### - Install service elasticsearch

```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt update
apt install elasticsearch
```

### Change configuration file(s)

`vim /etc/elasticsearch/elasticsearch.yml`

`grep -v "^#\|^$\|\s#" /etc/elasticsearch/elasticsearch.yml`

```text
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: localhost
http.port: 9200
```

### - Start service elasticsearch

```bash
systemctl start elasticsearch
systemctl enable elasticsearch
```

`INFO:` waiting ~30sec

`CHECK:`

```bash
curl -X GET "localhost:9200"
```

## 4. Kibana

### - Install service kibana

```bash
apt install kibana
```

### Change configuration file(s)

`vim /etc/kibana/kibana.yml`

`grep -v "^#\|^$\|\s#" /etc/kibana/kibana.yml`

```text
server.port: 5601
server.host: "localhost"
elasticsearch.hosts: "http://localhost:9200"
```

### - Start service kibana

```bash
systemctl start kibana
systemctl enable kibana
```

## 5. Logstash

### - Install service logstash

```bash
apt install logstash
```

`INFO:` [Help Elastic.co](https://www.elastic.co/guide/en/logstash/6.7/logstash-config-for-filebeat-modules.html#parsing-system)

### Change configuration file(s)

`vim /etc/logstash/conf.d/02-beats-input.conf`

[Open file 02-beats-input.conf](./logstash/02-beats-input.conf)

`vim /etc/logstash/conf.d/10-syslog-filter.conf`

[Open file 10-syslog-filter.conf](./logstash/10-syslog-filter.conf)

`vim /etc/logstash/conf.d/30-elasticsearch-output.conf`

[Open file 30-elasticsearch-output.conf](./logstash/30-elasticsearch-output.conf)

`CHECK:`

```bash
sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t
```

### - Start service logstash

```bash
systemctl start logstash
systemctl enable logstash
```

## 6. Filebeat

### - Install service filebeat

```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt update
apt install filebeat
```

### Change configuration file(s)

`vim /etc/filebeat/filebeat.yml`

`grep -v "^#\|^$\|\s#" /etc/filebeat/filebeat.yml`

```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
setup.template.settings:
  index.number_of_shards: 3
setup.kibana:
output.logstash:
  hosts: ["example.com:5044"]
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
```

### - Start service filebeat

```bash
systemctl start filebeat
systemctl enable filebeat
```

## 7. Heartbeat

### - Install service heartbeat

```bash
apt install heartbeat-elastic
```

### Change configuration file(s)

`vim /etc/heartbeat/heartbeat.yml`

`grep -v "^#\|^$\|\s#" /etc/heartbeat/heartbeat.yml`

```yaml
heartbeat.config.monitors:
  path: ${path.config}/monitors.d/*.yml
  reload.enabled: true
  reload.period: 15s
heartbeat.monitors:
setup.template.settings:
  index.number_of_shards: 1
  index.codec: best_compression
setup.kibana:
  host: "localhost:5601"
  username: "kibanaadmin"
  password: "password"
output.elasticsearch:
  hosts: ["localhost:9200"]
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
```

`vim /etc/heartbeat/monitors.d/elk-server.yml`

[Open file elk-server.yml](./heartbeat-elastic/elk-server.yml)

### - Start service heartbeat

```bash
systemctl start heartbeat-elastic
systemctl enable heartbeat-elastic
```

## 8. Configure Alert

`Create web hook for team` [AppHub WebEx.com](https://apphub.webex.com/integrations/incoming-webhooks-cisco-systems)

`Configure ELK Watcher`

[Open file watcher.json](alert/watcher.json)

`CHECK:`

```bash
curl -X POST -H "Content-Type: application/json" -d '{"text" : "This is a message from a Cisco Webex Teams incoming webhook."}'  "https://api.ciscospark.com/v1/webhooks/incoming/__id__"
```
