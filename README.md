# Touchcard

## Setting up local Development

Our app runs inside of the Shopify Admin, so local development requires connectivity 
to the Shopify.

### Set up Partner Account + Development Shop
Create a free Shopify Partner account at https://www.shopify.com/partners
Set up a development app under 'Apps'. Under the App Info tab, make sure to set: 

App Name = `https://YOUR_DEV_APP.ngrok.io/`
Whitelisted redirection URL = `https://touchcard.ngrok.io/auth/shopify/callback`

Remember your domain `YOUR_DEV_SHOP.myshopify.com` for later.

### Set up Rails, Gems, and NPM packages

Make sure you have `rvm` installed and the latest ruby as denoted in `Gemfile`

`gem install bundler`

`bundle install`

If you have problems with rubyracer / libv8 on Os X, try  `gem install libv8 -v '3.16.14.3' -- --with-system-v8` 
(make sure it's the right version) and / or `bundle update libv8`
[More info](https://stackoverflow.com/questions/19673714/error-installing-libv8-error-failed-to-build-gem-native-extension)

Install NPM packages 
`yarn install`

Set up the Database
`bundle exec rake db:drop db:create db:migrate db:seed RAILS_ENV=development`

Run the external proxy
This tunnels your localhost port 3000 to YOUR_DEV_APP.ngrok.io
`ngrok http -subdomain=YOUR_DEV_APP 3000`

Set up your local configs so the server doesn't give any errors.
Copy `local_env.yml.example` to `local_env.yml` Fill in any special credentials you have (`AWS_` keys, `APP_URL`, etc) 


Run the server
`bin/server`

Open `YOUR_DEV_APP.ngrok.io` in browser. You should get a screen that asks for your shopify url (`YOUR_DEV_SHOP.myshopify.com`). 
Enter that and click Ok, then it should ask you to install the app.

Once you've installed your shop you can optionally run this command to generate some fake data to help with development (the refresh):
`rake db:sample_data`


If you want to run the shop without embedding into the Touchcard admin you can set the `FULLSCREEN_DEBUG` environment variable. 
**This is experimental**, so I'd only recommend it if you're doing a lot of client reloading for javascript work, but not for testing, etc.

`FULLSCREEN_DEBUG=true bin/server`





## Deployment Process

1. Look up next tag version (v#.#.# format)
2. Update Changelog with changes & latest tag #.
3. Create branch, commit, push to Gitlab, merge into Master.
4. Ensure any ENV VAR updates are made.
5. Pull master & deploy to staging. `git push heroku-staging v1.X.X^{}:master`
6. Ensure migrations are run.
7. Manually smoke test staging. Repeat #2-7 until tests pass.
8. Tag master with tag version v#.#.#  (make sure commit matches staging)
9. Ensure any ENV Var updates are made.
10. Deploy tag to production. 
11. Make sure migrations are run.
12. Smoke test production.
13. Push tag to Gitlab.


# Heroku

[Heroku Rails 4 Commands](https://devcenter.heroku.com/articles/getting-started-with-rails4)


## Deployment

1. Push from local `development` branch to staging's `master` branch.


    git push heroku-staging development:master

2. Run a `db:migrate` if required


    heroku run rake db:migrate --app touchcard-staging


## Database Backup and Transfer

[SAFE transfer of production database to staging](http://stackoverflow.com/questions/10673630/how-do-i-transfer-production-database-to-staging-on-heroku-using-pgbackups-gett)

Or the Cowboy approach:

    heroku pg:copy touchcard::DATABASE_URL DATABASE_URL -a touchcard-staging


## AWS and S3

We use S3 in two unrelated ways:

1) We use it to host the postcards that are uploaded by users. This is on the following servers. These are accessed via the rails application.

`touchcard-data (production)`
`touchcard-data-staging`
`touchcard-data-dev`
