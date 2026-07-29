#!/bin/bash

echo "========================================"
echo "Employee Management System Deployment"
echo "========================================"

NGINX_CONFIG="/etc/nginx/sites-available/default"
NETWORK_NAME="employee-management-system_ems_network"


# Check current environment

if grep -q "proxy_pass http://127.0.0.1:5001;" "$NGINX_CONFIG"; then
    CURRENT="blue"
    NEXT="green"
    NEXT_PORT="5002"
    CONTAINER_NAME="ems_green_app"

elif grep -q "proxy_pass http://127.0.0.1:5002;" "$NGINX_CONFIG"; then
    CURRENT="green"
    NEXT="blue"
    NEXT_PORT="5001"
    CONTAINER_NAME="ems_blue_app"

else
    echo "ERROR: Unable to determine active environment."
    exit 1
fi


echo "Current Environment : $CURRENT"
echo "Next Environment    : $NEXT"
echo "Next Port           : $NEXT_PORT"

echo "Building Docker image..."
IMAGE_NAME="ems-${NEXT}:v1.0.0"

docker build -t $IMAGE_NAME .


echo "Removing old $CONTAINER_NAME if exists..."

docker rm -f $CONTAINER_NAME 2>/dev/null || true


echo "Starting $NEXT container..."


docker run -d \
  --name $CONTAINER_NAME \
  --network $NETWORK_NAME \
  -p $NEXT_PORT:5000 \
  -e DB_HOST=db \
  -e FLASK_ENV=production \
  $IMAGE_NAME



echo "Waiting for application startup..."

sleep 10


echo "Checking health..."

if curl -f http://localhost:$NEXT_PORT/health; then

    echo ""
    echo "$NEXT environment is healthy"


else

    echo ""
    echo "$NEXT environment failed health check"
    docker logs $CONTAINER_NAME
    exit 1

fi



echo "Switching Nginx traffic to $NEXT..."


if [ "$NEXT" = "green" ]; then

    sudo sed -i 's/5001/5002/g' $NGINX_CONFIG

else

    sudo sed -i 's/5002/5001/g' $NGINX_CONFIG

fi



echo "Testing Nginx configuration..."

sudo nginx -t


if [ $? -eq 0 ]; then

    sudo systemctl reload nginx

    echo "Traffic switched successfully to $NEXT"

else

    echo "Nginx test failed"
    exit 1

fi



echo "Deployment completed successfully"

echo "Active Environment: $NEXT"