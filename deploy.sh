#!/bin/bash

echo "========================================"
echo "Employee Management System Deployment"
echo "========================================"

NGINX_CONFIG="/etc/nginx/sites-available/default"

# Check which environment is currently active
if grep -q "proxy_pass http://127.0.0.1:5001;" "$NGINX_CONFIG"; then
    CURRENT="blue"
    NEXT="green"
elif grep -q "proxy_pass http://127.0.0.1:5002;" "$NGINX_CONFIG"; then
    CURRENT="green"
    NEXT="blue"
else
    echo "ERROR: Unable to determine active environment."
    exit 1
fi

echo "Current Environment : $CURRENT"
echo "Next Environment    : $NEXT"

# Start next environment

if [ "$NEXT" = "green" ]; then

    echo "Starting Green container..."

    docker build -t employee-management-system:latest .

    docker run -d \
      --name ems_green_app \
      --network employee-management-system_ems_network \
      -p 5002:5000 \
      -e DB_HOST=db \
      -e FLASK_ENV=production \
      employee-management-system:latest

fi