'use strict';

const puppeteer = require('puppeteer');

const createPdf = async() => {
  var ExitCode = Object.freeze({'success':0, 'fail':1})
  let browser, exitCode = ExitCode.fail;
  try {
    browser = await puppeteer.launch({args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1875,1275', '--allow-file-access-from-files'], headless: true});
    const page = await browser.newPage();
    //
    // await page.setCacheEnabled(false);

    let myArgs = process.argv.slice(2) // skip `/usr/local/bin/node` and  `[...]/touchcard/api/lib/headless/render.js`
    let enableNetworkThrottling = false
    if ( myArgs[0] == '--debug_network_throttle') {
      enableNetworkThrottling = true;
      myArgs.shift(); // remove '--debug_network_throttle' from arg array
    }
    let sourceFile = myArgs.shift();
    let targetFile = myArgs.shift();


    // For DEBUGGING / TESTING only - simulates slow network connection
    if (enableNetworkThrottling) {
      // Connect to Chrome DevTools
      const client = await page.target().createCDPSession()
      // Set throttling property
      await client.send('Network.emulateNetworkConditions', {
        'offline': false,
        'downloadThroughput': 200 * 1024 / 8,
        'uploadThroughput': 200 * 1024 / 8,
        'latency': 20
      });
    }

    if (!sourceFile || !targetFile) {
      throw new Error('Input and Output path required')
    }

    await page.goto(sourceFile, {timeout: 10 * 1000, waitUntil: 'networkidle0'});
    // To pass html directly use: `page.goto(`data:text/html,${htmlDoc}`, ...)`  or `page.setContent(htmlDoc, ...)`  (puppeteer v1.11.0)

    // const deviceScaleFactor = await page.evaluate(() => {
    //   return window.devicePixelRatio;
    // });
    // console.log("Device Scale Factor: " + deviceScaleFactor);

    await page.setViewport({width: 1875, height: 1275, deviceScaleFactor: 1});
    await page.on('console', msg => console.log('PAGE LOG:', msg.text()));

    // DEBUGGING:
    // const docHtml = await page.content();
    // await page.waitFor(10 * 1000);

    await page
      .waitForSelector('div.render-complete', {timeout: 10 * 1000})
      .then(() => {
        console.log('found render-complete');
        exitCode = ExitCode.success;
      })
      .catch( err => {
        console.log(err);
      });

    await page.screenshot({
      path: targetFile,
      printBackground: true
    });

  } catch (err) {
      console.log(err.message);

  } finally {
    if (browser) {
      browser.close();
    }
    process.exit(exitCode);
  }
};
createPdf();


