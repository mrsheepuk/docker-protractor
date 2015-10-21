FROM library/java:8-jre

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get install -y \
  xvfb \
  libgconf-2-4 \
  libexif12 \
  chromium \
  npm \
  supervisor \
  netcat-traditional

# install ffmpeg
RUN curl http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2015.6.1_all.deb \
  -o /tmp/deb-multimedia-keyring_2015.6.1_all.deb && \
  dpkg -i /tmp/deb-multimedia-keyring_2015.6.1_all.deb && \
  rm /tmp/deb-multimedia-keyring_2015.6.1_all.deb

RUN echo "deb http://www.deb-multimedia.org jessie main non-free" >> /etc/apt/sources.list && \
  echo "deb http://www.deb-multimedia.org jessie-backports main" >> /etc/apt/sources.list

RUN apt-get update

RUN apt-get install -y \
  ffmpeg

# remove packages & listings to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install -g protractor

# Install Selenium and Chrome driver
RUN webdriver-manager update

# Add a non-privileged user for running Protrator
RUN adduser --home /project --uid 1100 \
  --disabled-login --disabled-password --gecos node node

# Add service defintions for Xvfb, Selenium and Protractor runner
ADD supervisord/*.conf /etc/supervisor/conf.d/

# By default, tests in /data directory will be executed once and then the container
# will quit. When MANUAL envorinment variable is set when starting the container,
# tests will NOT be executed and Xvfb and Selenium will keep running.
ADD bin/run-protractor /usr/local/bin/run-protractor

# Container's entry point, executing supervisord in the foreground
CMD ["/usr/bin/supervisord", "-n"]

# Protractor test project needs to be mounted at /project
VOLUME ["/project"]
