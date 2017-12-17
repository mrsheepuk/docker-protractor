FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update --fix-missing && \
  apt-get install -y \
    wget \
    curl \
    build-essential \
    libssl-dev \
    openjdk-8-jre \
    xvfb \
    libgconf-2-4 \
    libexif12 \
    firefox \
    supervisor \
    netcat-traditional \
    ffmpeg && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*



RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
  apt-get update && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y chromium-browser

RUN npm install -g protractor@4.0.x


# Install Selenium and Chrome driver
RUN webdriver-manager update

# Add a non-privileged user for running Protrator
RUN adduser --home /project --uid 1100 \
  --disabled-login --disabled-password --gecos node node

# Add main configuration file
ADD supervisor.conf /etc/supervisor/supervisor.conf

# Add service defintions for Xvfb, Selenium and Protractor runner
ADD supervisord/*.conf /etc/supervisor/conf.d/

# Container's entry point, executing supervisord in the foreground
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisor.conf"]

# Protractor test project needs to be mounted at /project
VOLUME ["/project"]
