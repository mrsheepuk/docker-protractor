Dockerfile for [Protractor](http://angular.github.io/protractor/) test execution
================================================================================

Based on [caltha/protractor](https://bitbucket.org/rkrzewski/dockerfile), this image contains a fully configured environment for running Protractor tests under Chromium and Firefox browsers.

This version additionally supports linking docker containers together to test software in another container, and passing a custom base URL into your protractor specs so you don't have to hard-code the URL in them. 

Installed software
------------------
   * [Xvfb](http://unixhelp.ed.ac.uk/CGI/man-cgi?Xvfb+1) The headless X server, for running browsers inside Docker
   * [node.js](http://nodejs.org/) The runtime platform for running JavaScript on the server side, including Protractor tests
   * [npm](https://www.npmjs.com/) Node.js package manager used to install Protractor and any specific node.js modules the tests may need
   * [Selenium webdriver](http://docs.seleniumhq.org/docs/03_webdriver.jsp) Browser instrumentation agent used by Protractor to execute the tests
   * [Java 8 SE](http://www.oracle.com/technetwork/java/javase/) Needed by Selenium
   * [Chromium](http://www.chromium.org/Home) The OSS core part of Google Chrome browser
   * [Firefox](https://www.mozilla.org/en-US/firefox/desktop/) Firefox browser
   * [Protractor](http://angular.github.io/protractor/) An end-to-end test framework for web applications
   * [Supervisor](http://supervisord.org/) Process controll system used to manage Xvfb and Selenium background processes needed by Protractor

Running
-------
In order to run tests from a CI system, execute the following:
```
docker run --rm -v <test project location>:/project mrsheepuk/protractor
```
The container will terminate automatically after the tests are completed. The output of supervisord visible on the console is not interesting in most circumstances. You should check `target/supervisor.out` file to see the output of Protractor. Displaying the file in an Unix terminal using `cat` is recommended over opening it using an editor because the file contains ANSI escape sequences.

To run against another container, execute as follows (this example assumes that the image you are testing exposes its web site on port 3000):
```
docker run -d --name=webe2e <image to test>
docker run --rm --link=webe2e:webe2e -v <test project location>:/project --env BASEURL=http://webe2e:3000/ mrsheepuk/protractor
docker rm -f webe2e
```

You can also use the BASEURL variable without container linking, to test any arbitrary web site. If you wish to use the BASEURL functionality, you must use relative URLs within your test specs (e.g. `browser.get("/profile/")` instead of `browser.get("http://test.com/profile/")`.

If you want to run the tests interactively you can launch the container and enter into it:
```
CONTAINER=$(docker run -d -v <test project location>:/project --env MANUAL=yes mrsheepuk/protractor)
docker exec -ti $CONTAINER sudo -i -u node bash
```
When inside the container you can run the tests at the console by simply invoking `protractor`. When things don't work as expected, you should check Selenium WebDrover output in `/var/log/supervisor/webdriver-err.log`. When you are done, you terminate the Protractor container with `docker kill $CONTAINER`
