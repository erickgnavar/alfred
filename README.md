# Alfred

## Installation

Setup environment variables

```
export BOT_NAME="alfred"
export JENKINS_URL="jenkins.mydomain.com"
export JENKINS_USER_ID="admin"
export JENKINS_API_TOKEN="super secret token"
export SLACK_TOKEN="slack token"
```

## Run

```
mix run --no-halt
```

## Run in a Docker container

Build the image

```
docker build -t alfred .
```

Execute as a daemon

```
docker run \
    -e JENKINS_URL="" \
    -e SLACK_TOKEN="" \
    -e JENKINS_USER_ID="" \
    -e JENKINS_API_TOKEN="" \
    -e BOT_NAME="alfred"
    --restart=always \
    --detach=true \
    --name=alfred \
    alfred
```

## Features

- Jenkins integration: allow see jobs status and trigger builds
