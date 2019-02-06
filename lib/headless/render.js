'use strict';

const puppeteer = require('puppeteer');

const createPdf = async() => {
  var ExitCode = Object.freeze({'success':0, 'fail':1})
  let browser, exitCode = ExitCode.fail;
  try {
    browser = await puppeteer.launch({args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1875,1275', '--allow-file-access-from-files'], headless: true});
    const page = await browser.newPage();

    await page.goto(process.argv[2], {timeout: 3000, waitUntil: 'networkidle2'});
    // To pass html directly use: `page.goto(`data:text/html,${htmlDoc}`, ...)`  or `page.setContent(htmlDoc, ...)`  (puppeteer v1.11.0)

    // const deviceScaleFactor = await page.evaluate(() => {
    //   return window.devicePixelRatio;
    // });
    // console.log("Device Scale Factor: " + deviceScaleFactor);

    await page.setViewport({width: 1875, height: 1275, deviceScaleFactor: 1});
    await page.on('console', msg => console.log('PAGE LOG:', msg.text()));

    // Document HTML (for debugging)
    // const docHtml = await page.content();


    await page
      .waitForSelector('div.render-complete', {timeout: 10 * 1000})
      .then(() => {
        console.log('found render-complete');
        exitCode = ExitCode.success;
      })
      .catch( err => {
        console.log(err);
      });


    // TODO: Fix deviceScaleFactor

    // DEBUGGING... IN IRB:
    // require "shellwords"
    // back_html_path = "//Users/dustin/code/touchcard/api/tmp/lob/fc9979fa-6a8b-4484-b8c1-5ef6b4568553_input.html"
    // front_html_path = "//Users/dustin/code/touchcard/api/tmp/lob/bac72e3e-bf7e-4129-aab6-94f05cc0910e_input.html"
    // html_path = front_html_path
    // png_path = "./test_output.png"
    // result =  system("node lib/headless/render.js file:///#{Shellwords.escape(html_path)} #{Shellwords.escape(png_path)}")

    // TODO: AND NOW DOW THIS....
    // Get tests working, including deviceScaleFactor
    // Upgrade to Heroku 18
    // Set up buildpack & run on Heroku
    // look into testing on Heroku

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
    process.exit(exitCode);
  }
};
createPdf();


