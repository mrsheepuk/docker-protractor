FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update --fix-missing && \
  apt-get install -y \
  git \
  apt-utils \
  wget \
  curl \
  build-essential \
  libssl-dev \
  openjdk-8-jre \
  xvfb \
  libgconf-2-4 \
  libexif12 \
  firefox \
  netcat-traditional \
  jq \
  ffmpeg \
  chromium-browser

RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" > /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Set the locale (dates may be borked in protractor if not)
RUN apt-get update && apt-get install -y locales locales-all
RUN locale-gen en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en
ENV LC_ALL en_GB.UTF-8


RUN apt-get install -y google-cloud-sdk \
  nodejs

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Add a non-privileged user for running Protrator
RUN adduser --home /project --uid 1100 \
  --disabled-login --disabled-password --gecos node node

# Add main configuration file
ADD supervisor.conf /etc/supervisor/supervisor.conf

# Add service defintions for Xvfb
ADD supervisord/*.conf /etc/supervisor/conf.d/

# Container's entry point, executing supervisord in the foreground
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisor.conf"]

# Protractor test project needs to be mounted at /project
VOLUME ["/project"]
