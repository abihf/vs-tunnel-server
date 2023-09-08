#!/bin/bash

if [ -d /home/linuxbrew/.linuxbrew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

LOCAL_BIN="/home/ubuntu/.local/bin"
CODE="${LOCAL_BIN}/code"
CODE_INSIDERS="${LOCAL_BIN}/code-insiders"

if [ ! -x "${CODE}" ]; then
  mkdir -p "${LOCAL_BIN}"
  curl -sL "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64" | tar xvzC "${LOCAL_BIN}"
else
  "${CODE}" update
fi

exec /usr/local/bin/supervisord -c /etc/supervisor.conf
