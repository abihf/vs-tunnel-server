#!/bin/bash

if [ -d /home/linuxbrew/.linuxbrew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

exec /usr/local/bin/supervisord -c /etc/supervisor.conf
