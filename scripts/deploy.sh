#!/bin/bash
#
# Assuming you have the latest version Docker installed, this script will
# fully create or update an environment to test your patch.
#
set -e

HERE="$(pwd)"

echo ''
echo 'About to try to get the latest version of'
echo 'https://hub.docker.com/r/dcycle/drupal/ from the Docker hub. This image'
echo 'is updated automatically every Wednesday with the latest version of'
echo 'Drupal and Drush. If the image has changed since the latest deployment,'
echo 'the environment will be completely rebuild based on this image.'
docker pull dcycle/drupal:8

echo ''
echo '-----'
echo 'About to start persistent (-d) containers based on the images defined'
echo 'in ./Dockerfile and ./docker-compose.yml. We are also telling'
echo 'docker-compose to rebuild the images if they are out of date.'
docker-compose up -d --build

echo ''
echo '-----'
echo 'Running the deploy script on the running containers. This installs'
echo 'Drupal if it is not yet installed.'
docker-compose exec drupal /docker-resources/scripts/deploy.sh

if [ ! -f ./drupal/WHERE-ARE-FILES-OTHER-THAN-CORE.md ]; then
  cp ./scripts/lib/WHERE-ARE-FILES-OTHER-THAN-CORE.md ./drupal/WHERE-ARE-FILES-OTHER-THAN-CORE.md
fi
if [ ! -d ./drupal/.git ]; then
  cd ./drupal && echo .DS_Store >> .gitignore && git init && git add . && git commit -am 'Initial pre-patch commit'
fi

echo ''
echo '-----'
echo ''
echo 'If all went well you can now access your site at:'
cd "$HERE" && ./scripts/uli.sh
echo '-----'
echo ''
