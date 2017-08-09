FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update --fix-missing && \
  apt-get install -y \
    wget \
    build-essential \
    libssl-dev \
    openjdk-8-jre \
    xvfb \
    libgconf-2-4 \
    libexif12 \
    chromium-browser \
    firefox \
    npm \
    nodejs \
    supervisor \
    netcat-traditional \
    ffmpeg && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*


RUN ln -s /usr/bin/nodejs /usr/bin/node

#RUN node --version

# Upgrade NPM to latest (address issue #3)
RUN npm install -g npm

RUN npm install -g n

# Install node.js 6.11.2
RUN n 6.11.2

RUN nodejs --version

# Install Protractor
RUN npm install -g protractor

# Install Selenium and Chrome driver
RUN webdriver-manager update

# Add a non-privileged user for running Protrator
RUN adduser --home /project --uid 1100 \
  --disabled-login --disabled-password --gecos node node

# Add main configuration file
ADD supervisor.conf /etc/supervisor/supervisor.conf

# Add service defintions for Xvfb, Selenium and Protractor runner
ADD supervisord/*.conf /etc/supervisor/conf.d/

# By default, tests in /data directory will be executed once and then the container
# will quit. When MANUAL envorinment variable is set when starting the container,
# tests will NOT be executed and Xvfb and Selenium will keep running.
ADD bin/run-protractor /usr/local/bin/run-protractor

# Container's entry point, executing supervisord in the foreground
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisor.conf"]

# Protractor test project needs to be mounted at /project
VOLUME ["/project"]
