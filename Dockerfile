FROM ubuntu:23.10 AS code-cli
ADD "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64" /code.tar.gz
RUN tar xvf code.tar.gz

FROM ubuntu:23.10

RUN apt-get update
RUN --mount=type=cache,target=/var/cache/apt/archives \
  rm /etc/apt/apt.conf.d/docker-clean && \
  apt-get install -y -q curl sudo vim zsh yadm git build-essential 
RUN echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nopasswd
RUN mkdir /home/linuxbrew && \
  chown ubuntu:ubuntu /home/linuxbrew && \
  ln -s /home/ubuntu/.local/share/brew /home/linuxbrew/.linuxbrew && \
  ln -s /home/ubuntu/.local/share/brew /linuxbrew

COPY --link --from=code-cli /code /usr/local/bin/code
ADD --link --chmod=0755 "https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64" /tini
ADD --chmod=0755 start-tunnel.sh /start-tunnel.sh

USER ubuntu
WORKDIR /home/ubuntu
ENTRYPOINT [ "/tini", "--" ]
CMD [ "/start-tunnel.sh" ]
