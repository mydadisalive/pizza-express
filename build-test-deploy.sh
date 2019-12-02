#!/bin/bash 
set -e

# this script builds tests and deploys the app
# this script uses set -e which will exit upon any error

echo "======================"
echo "= running unit tests ="
echo "======================"
npm test

echo "================"
echo "= building app ="
echo "================"
docker-compose build 

echo "==============="
echo "= running app ="
echo "==============="
docker-compose up -d

echo "========================"
echo "= testing availability ="
echo "========================"
curl http://localhost:8082
