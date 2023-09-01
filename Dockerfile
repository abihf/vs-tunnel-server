ARG BASE_IMAGE=ubuntu:23.10

# FROM ${BASE_IMAGE} AS code-cli
# ENV test=1
# ADD "https://code.visualstudio.com/sha/download?build=insider&os=cli-alpine-x64" /code.tar.gz
# RUN tar xvf code.tar.gz

FROM ${BASE_IMAGE} AS supervisord
ARG SUPERVISORD_VERSION="0.7.3"
ADD "https://github.com/ochinchina/supervisord/releases/download/v${SUPERVISORD_VERSION}/supervisord_${SUPERVISORD_VERSION}_Linux_64-bit.tar.gz" /supervisord.tar.gz
RUN tar xvf supervisord.tar.gz --strip-components=1

# ------------------------------------------------------------

FROM ${BASE_IMAGE}

# packages
RUN apt-get update
RUN --mount=type=cache,target=/var/cache/apt/archives \
  rm /etc/apt/apt.conf.d/docker-clean && \
  apt-get install -y -q curl sudo vim zsh yadm git build-essential libsecret-1-0

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

ADD --link --chmod=0755 "https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64" /tini
COPY --link --from=supervisord /supervisord /usr/local/bin/
RUN curl -sL "https://code.visualstudio.com/sha/download?build=insider&os=cli-alpine-x64" | tar xvzC /usr/local/bin/
# COPY --link --from=code-cli /code-insiders /usr/local/bin/
ADD --chmod=0755 entrypoint.sh /entrypoint.sh
ADD --chmod=0644 supervisor.conf /etc/

EXPOSE 8000
USER ubuntu
WORKDIR /home/ubuntu
ENTRYPOINT [ "/tini", "--" ]
CMD [ "/entrypoint.sh" ]
