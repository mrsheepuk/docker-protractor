Dockerfile for [Protractor](http://angular.github.io/protractor/) test execution
================================================================================

Based on [caltha/protractor](https://bitbucket.org/rkrzewski/dockerfile), this image contains a fully configured environment for running Protractor tests under the Chromium browser.

This version additionally supports linking docker containers together to test software in another container, and passing a custom base URL into your protractor specs so you don't have to hard-code the URL in them. 

Installed software
------------------
   * [Xvfb](http://unixhelp.ed.ac.uk/CGI/man-cgi?Xvfb+1) The headless X server, for running browsers inside Docker
   * [node.js](http://nodejs.org/) The runtime platform for running JavaScript on the server side, including Protractor tests
   * [npm](https://www.npmjs.com/) Node.js package manager used to install Protractor and any specific node.js modules the tests may need
   * [Selenium webdriver](http://docs.seleniumhq.org/docs/03_webdriver.jsp) Browser instrumentation agent used by Protractor to execute the tests
   * [OpenJDK 8 JRE](http://openjdk.java.net/projects/jdk8/) Needed by Selenium
   * [Chromium](http://www.chromium.org/Home) The OSS core part of Google Chrome browser
   * [Firefox](https://www.mozilla.org) Firefox browser
   * [Protractor](http://angular.github.io/protractor/) An end-to-end test framework for web applications
   * [Supervisor](http://supervisord.org/) Process controll system used to manage Xvfb and Selenium background processes needed by Protractor

Running
-------
In order to run tests from a CI system, execute the following:
```
docker run --rm -v <test project location>:/project flexys/docker-protractor
```
The container will terminate automatically after the tests are completed.

To run against another container, execute as follows (this example assumes that the image you are testing exposes its web site on port 3000):
```
docker run -d --name=webe2e <image to test>
docker run --rm --link=webe2e:webe2e -v <test project location>:/project --env BASEURL=http://webe2e:3000/ flexys/docker-protractor
docker rm -f webe2e
```

You can also use the BASEURL variable without container linking, to test any arbitrary web site. If you wish to use the BASEURL functionality, you must use relative URLs within your test specs (e.g. `browser.get("/profile/")` instead of `browser.get("http://test.com/profile/")`.

If you want to run the tests interactively you can launch the container and enter into it:
```
CONTAINER=$(docker run -d -v <test project location>:/project --env MANUAL=yes flexys/docker-protractor)
docker exec -ti $CONTAINER sudo -i -u node bash
```
When inside the container you can run the tests at the console by simply invoking `protractor`. When you are done, you terminate the Protractor container with `docker kill $CONTAINER`.

Your protractor.conf.js must specify the no-sandbox option for Chrome to cleanly run inside Docker. A minimal example config would be:

```
exports.config = {
  seleniumAddress: 'http://localhost:4444/wd/hub',
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
