#!/bin/sh
set -e

echo "Waiting for NPM API (max 60 seconds)..."
i=0
while [ $i -lt 12 ]; do
  if curl -s http://nginx-proxy-manager:81/api/ > /dev/null; then
    echo "NPM API is up!"
    break
  fi
  echo "Waiting... ($i/12)"
  sleep 5
  i=$((i + 1))
done

if [ $i -eq 12 ]; then
  echo "Failed to connect to NPM API after 60 seconds"
  exit 1
fi

echo "Logging into NPM..."
RESPONSE=$(curl -s -X POST http://nginx-proxy-manager:81/api/tokens \
  -H "Content-Type: application/json" \
  -d '{"identity":"'"$NPM_USER"'","secret":"'"$NPM_PASS"'"}')
TOKEN=$(echo "$RESPONSE" | jq -r .token)

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
  echo "Failed to log into NPM API. Response: $RESPONSE"
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

create_proxy_host "home.lan" "homepage" 3000
create_proxy_host "pihole.home.lan" "pihole" 80
create_proxy_host "npm.home.lan" "nginx-proxy-manager" 81
create_proxy_host "portainer.home.lan" "portainer" 9000

echo "Proxy hosts created successfully!"