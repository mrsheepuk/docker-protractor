Dockerfile for [Protractor](http://angular.github.io/protractor/) test execution
================================================================================

Based on [caltha/protractor](https://bitbucket.org/rkrzewski/dockerfile), this image contains a fully configured environment for running Protractor tests under the Chromium browser.

This version additionally supports linking docker containers together to test software in another container, and passing a custom base URL into your protractor specs so you don't have to hard-code the URL in them.

Installed software
------------------
   * [locales][http://jaredmarkell.com/docker-and-locales/] This image is configures to en_GB as this is where we test.
   * [Xvfb](http://unixhelp.ed.ac.uk/CGI/man-cgi?Xvfb+1) The headless X server, for running browsers inside Docker
   * [node.js](http://nodejs.org/) The runtime platform for running JavaScript on the server side, including Protractor tests
   * [npm](https://www.npmjs.com/) Node.js package manager used to install Protractor and any specific node.js modules the tests may need
   * [OpenJDK 8 JRE](http://openjdk.java.net/projects/jdk8/) Needed by Selenium
   * [Chromium](http://www.chromium.org/Home) The OSS core part of Google Chrome browser
   * [Firefox](https://www.mozilla.org) Firefox browser
   * [Protractor](http://angular.github.io/protractor/) An end-to-end test framework for web applications
   * [Supervisor](http://supervisord.org/) Process controll system used to manage Xvfb

Running
-------
I have stripped out the automatic running of protractor as we inject the tests through [Concourse](http://concourse.ci)

When inside the container you can run the tests at the console by simply invoking `protractor`. When you are done, you terminate the Protractor container with `docker kill $CONTAINER`.

Your protractor.conf.js must specify the no-sandbox option for Chrome to cleanly run inside Docker. A minimal example config would be:

```
exports.config = {
  directConnect: true,
  framework: "jasmine2",
  specs: ['*.spec.js'],
  // Chrome is not allowed to create a SUID sandbox when running inside Docker  
  capabilities: {
    'browserName': 'chrome',
    'chromeOptions': {
      'args': ['no-sandbox']
    }
  }
};
```
