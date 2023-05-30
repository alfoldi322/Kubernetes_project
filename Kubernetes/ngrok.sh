#!/bin/bash

# Start ngrok tunnel on port 80
ngrok http 8080

sleep 5

# Get the ngrok link and print it to Jenkins build log
ngrok_link=$(curl -s http://localhost:4040/api/tunnels | grep -o 'https://[^"]*')
echo "Ngrok tunnel link: ${ngrok_link}"