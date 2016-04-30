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

