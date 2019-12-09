#!/bin/bash 

# this script builds tests and deploys the app

set -e # exit upon any error
#set -x # set for debug

# source environment variables
. .env

function build()
{
echo "========="
echo "= build ="
echo "========="
docker-compose build 
docker tag "${USER}/${IMAGE}:${VER}" "${USER}/${IMAGE}:latest"
docker-compose up -d
sleep 5
}

function test_app()
{
echo "========"
echo "= test ="
echo "========"
docker exec -it pizza-express npm test
}

function deploy()
{
echo "=========="
echo "= deploy ="
echo "=========="
}

function monitor()
{
sleep 5
echo "==========="
echo "= monitor ="
echo "==========="
[[ `curl -sL -w "%{http_code}\\n" "http://localhost:$PORT" -o /dev/null` == "200" ]] && echo "curl ok" || ( echo "curl failed" && exit 1 )
}

function push()
{
echo "========"
echo "= push ="
echo "========"
docker push "${USER}/${IMAGE}:${VER}"
docker push "${USER}/${IMAGE}:latest"
}

function clean()
{
echo "========"
echo "= clean ="
echo "========"
# clean up dangling images
docker image prune -f
}

function all()
{

  build
  test_app
  deploy
  monitor
  push
  clean

}



function help_menu ()
{
cat << EOF
Usage: ${0} (-h | -b | -t | -d | -m | -p | -c )
  OPTIONS:
  	-h|--help 			Show this message
  	-b|--build			Build app
  	-t|--test 			Test app
  	-d|--deploy 			Deploy app
  	-m|--monitor 			Monitor connectivity
  	-p|--push 			Push to dockerhub
  	-c|--clean 			Clean dangling images
  	-a|--all 			Run a full cycle of build test and deploy
EOF
}

[[ $# == 0 ]] && help_menu && exit 1

while [[ $# > 0 ]]
do
case "${1}" in
	-b|--build)
	build
	shift
	;;
	-t|--test)
	test_app
	shift
	;;
	-d|--deploy)
	deploy
	shift
	;;
	-m|--monitor)
	monitor
	shift
	;;
	-p|--push)
	push
	shift
	;;
	-c|--clean)
	clean
	shift
	;;
	-a|--all)
	all
	shift
	;;
	-h|--help)
	help_menu
	shift
	;;
	*)
	echo "${1} is not a valid flag, try running: ${0} --help"
	;;
esac
shift
done
