#!/bin/sh
set -e

echo "Waiting for NPM API..."
until curl -s http://nginx-proxy-manager:81/api/ > /dev/null; do
  sleep 5
done

echo "Logging into NPM..."
TOKEN=$(curl -s -X POST http://nginx-proxy-manager:81/api/tokens \
  -H "Content-Type: application/json" \
  -d '{"identity":"'"$NPM_USER"'","secret":"'"$NPM_PASS"'"}' | jq -r .token)

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
  echo "Failed to log into NPM API"
  exit 1
fi

echo "Creating proxy hosts..."

# Function to create proxy host
create_proxy_host() {
  DOMAIN=$1
  TARGET=$2
  PORT=$3
  echo " → $DOMAIN → $TARGET:$PORT"
  curl -s -X POST http://nginx-proxy-manager:81/api/nginx/proxy-hosts \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "domain_names":["'"$DOMAIN"'"],
      "forward_scheme":"http",
      "forward_host":"'"$TARGET"'",
      "forward_port":'"$PORT"',
      "block_exploits":true,
      "caching_enabled":false,
      "allow_websocket_upgrade":true,
      "access_list_id":0,
      "certificate_id":0,
      "ssl_forced":false,
      "enabled":true
    }' > /dev/null
}

create_proxy_host "pihole.home.lan" "pihole" 80
create_proxy_host "npm.home.lan" "nginx-proxy-manager" 81
create_proxy_host "portainer.home.lan" "portainer" 9000

echo "Proxy hosts created successfully!"
