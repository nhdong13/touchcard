#Touchcard
Get better customer engagement with thank you postcards!



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

touchcard-data (production)
touchcard-data-staging
touchcard-data-dev


2) We use it to host our client Ember application, which is deployed via the ember cli lightning deploy method. The rails application is not directly aware of these. It only knows of the location via the attached redis instance. The ember client deploys directly to these buckets.

touchcard-client (production)
touchcard-client-staging
touchcard-client-dev


