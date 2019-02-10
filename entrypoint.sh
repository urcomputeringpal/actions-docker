#!/bin/bash

set -e

: ${REGISTRY:=gcr.io}
: ${IMAGE:=$GITHUB_REPOSITORY}
: ${TAG:=$GITHUB_SHA}
: ${DEFAULT_BRANCH_TAG:=true}

if [ -n "${GCLOUD_SERVICE_ACCOUNT_KEY}" ]; then
  echo "Logging into gcr.io with GCLOUD_SERVICE_ACCOUNT_KEY..."
  echo ${GCLOUD_SERVICE_ACCOUNT_KEY} | base64 --decode > /tmp/key.json
  gcloud auth activate-service-account --quiet --key-file /tmp/key.json
  gcloud auth configure-docker --quiet
else
  echo "GCLOUD_SERVICE_ACCOUNT_KEY was empty, not performing auth" 1>&2
fi

if [ "$1" = "build" ]; then
  docker build -t $IMAGE:$TAG .
  docker tag $IMAGE:$TAG $REGISTRY/$IMAGE:$TAG
  if [ "$DEFAULT_BRANCH_TAG" = "true" ]; then
    BRANCH=$(echo $GITHUB_REF | rev | cut -f 1 -d / | rev)
    if [ "$BRANCH" = "master" ]; then # TODO
      docker tag $IMAGE:$TAG $REGISTRY/$IMAGE:$BRANCH
    fi
  fi
elif [ "$1" = "push" ]; then
  docker push $REGISTRY/$IMAGE
else
  echo "Unknown action $1" 1>&2
  exit 1
fi
