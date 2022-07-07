#!/bin/bash
SCRIPT="$0"
PATH=$(realpath "$0")
ENV=$1
APP="$2"
IMAGE_TAG="$3"

if [ "$1" = "" ]; then
  echo "
  Free-Work Deploy Tool

  To deploy, run:
  ./deploy {env} {app} {image_tag}

  {env} must be 'prod', 'preprod', 'dev', 'review1', 'review2' or 'review3'
  {app} must be 'front', 'back' or 'nginx'
  {image_tag} must be the docker image tag of the app ('v1.0.31', 'review-2e5e1d8e', 'dev-4e8e2a71', ...)"
  exit
fi

# valid env argument
array=(prod preprod dev review1 review2 review3)
if [[ ! "${array[*]}" =~ "$ENV" ]]; then
  echo
  echo "The 'env' argument must be 'prod', 'preprod', 'dev', 'review1', 'review2' or 'review3'. '${ENV}' provided."
  echo "Deployment aborted"
    exit 1
fi

# valid app argument
array=(front back)
if [[ ! "${array[*]}" =~ "$APP" ]]; then
  echo
  echo "The 'app' argument must be 'front', 'back' or 'nginx'. '${APP}' provided."
  echo "Deployment aborted"
  exit 1
fi

# echo parameters
echo "ENV: $ENV"
echo "APP: $APP"
echo "IMAGE_TAG: $IMAGE_TAG"
echo

# first confirm
read -p "Are you sure you want to deploy? (y/n) " -r
echo    # (optional) move to a new line

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Deployment aborted"
    exit 1
fi

# second confirm if prod env
if [ "$ENV" = "prod" ]; then
  echo
  echo "/!\\ PROD /!\\"
  read -p "If you want to deploy on the prod environment, type 'yes': " -r
  echo

  if [ "$REPLY" != "yes" ]; then
      echo "Deployment aborted"
      exit 1
  fi
fi

# load conf
. "$PATH/fw-deploy.conf"

# start deploy
if [[ "$APP" == "front" ]]; then
 PROJECTS=("frontend/frontend")
else
  PROJECTS=("backend/backend" "nginx/nginx")
fi

echo "Deploy..."

for (( i=0; i<${#PROJECTS[@]}; i++ )); do
  if [[ $i -gt 0 ]]; then
    sleep 90
  fi
  echo
  echo "> ${PROJECTS[i]}"
  curl --request POST 'https://gitlab.free-work.mysk5.com/api/v4/projects/2/trigger/pipeline' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "ref": "master",
      "token": "'${TOKEN}'",
      "variables": {
        "ENVIRONMENT": "'${ENV}'",
        "PROJECT": "'${PROJECTS[i]}'",
        "IMAGE_TAG": "'${IMAGE_TAG}'",
        "TYPE": "'${TYPE}'"
      }
    }'
    echo
done

echo
echo "🚀"
exit