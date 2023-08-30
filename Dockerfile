FROM ubuntu:23.10 AS code-cli
ADD "https://code.visualstudio.com/sha/download?build=insider&os=cli-alpine-x64" /code.tar.gz
RUN tar xvf code.tar.gz

# ------------------------------------------------------------

FROM ubuntu:23.10

# packages
RUN apt-get update
RUN --mount=type=cache,target=/var/cache/apt/archives \
  rm /etc/apt/apt.conf.d/docker-clean && \
  apt-get install -y -q curl sudo vim zsh yadm git build-essential 

# sudo no password
RUN echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nopasswd

# brew
RUN mkdir /home/linuxbrew && \
  chown ubuntu:ubuntu /home/linuxbrew && \
  ln -s /home/ubuntu/.local/share/brew /home/linuxbrew/.linuxbrew && \
  ln -s /home/ubuntu/.local/share/brew /linuxbrew

# docker no sudo
RUN groupadd -g 971 -r docker && \
  usermod -aG docker ubuntu

COPY --link --from=code-cli /code-insiders /usr/local/bin/
ADD --link --chmod=0755 "https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64" /tini
ADD --chmod=0755 start-tunnel.sh /start-tunnel.sh

USER ubuntu
WORKDIR /home/ubuntu
ENTRYPOINT [ "/tini", "--" ]
CMD [ "/start-tunnel.sh" ]
