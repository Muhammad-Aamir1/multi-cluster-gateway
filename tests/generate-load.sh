#!/bin/bash
# tests/generate-load.sh

# CONFIG
GATEWAY_URL="https://store.example.com" # Replace with your IP or Domain

echo "Starting load test against $GATEWAY_URL..."
echo "Press CTRL+C to stop."
echo "---------------------------------------------------"
echo "TIME | STATUS | REGION (Server Name)"
echo "---------------------------------------------------"

while true; do
  # Extract HTTP Code and the Server Name from the HTML response
  # valid response looks like: "Server Name: store-app-..."
  
  TIMESTAMP=$(date +"%T")
  RESPONSE=$(curl -s -w "%{http_code}" $GATEWAY_URL)
  HTTP_CODE=${RESPONSE: -3}
  CONTENT=${RESPONSE:0:${#RESPONSE}-3}
  
  # Grep the server name for visibility
  SERVER_NAME=$(echo "$CONTENT" | grep -o "Server Name: [^<]*" | cut -d: -f2 | xargs)

  if [ "$HTTP_CODE" == "200" ]; then
    echo "$TIMESTAMP | $HTTP_CODE    | $SERVER_NAME"
  else
    echo "$TIMESTAMP | $HTTP_CODE    | (Request Failed - Failover in progress?)"
  fi
  
  sleep 1
done
