'use strict';

const puppeteer = require('puppeteer');

const createPdf = async() => {
  let browser;
  try {
    browser = await puppeteer.launch({args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1875,1275', '--allow-file-access-from-files'], headless: true});
    const page = await browser.newPage();

    await page.goto(process.argv[2], {timeout: 3000, waitUntil: 'networkidle2'});
    // To pass html directly use: `page.goto(`data:text/html,${htmlDoc}`, ...)`  or `page.setContent(htmlDoc, ...)`  (puppeteer v1.11.0)

    // const deviceScaleFactor = await page.evaluate(() => {
    //   return window.devicePixelRatio;
    // });
    // console.log("Device Scale Factor: " + deviceScaleFactor);

    await page.setViewport({width: 1875, height: 1275, deviceScaleFactor: 2});
    await page.on('console', msg => console.log('PAGE LOG:', msg.text()));

    await page.waitFor(250);  // Wait, just in case?

    // TODO: Fix deviceScaleFactor
    // TODO: wait for `div.render-complete` in page
    // TODO: raise error if rendering fails


    await page.screenshot({
      path: process.argv[3],
      printBackground: true
    });

  } catch (err) {
      console.log(err.message);
  } finally {
    if (browser) {
      browser.close();
    }
    process.exit();
  }
};
createPdf();


