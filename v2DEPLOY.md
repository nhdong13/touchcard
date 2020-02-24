DB backup in Heroku admin

Make a backup DB so the old one is ready on stand-by without wait
heroku addons:create heroku-postgresql:standard-1 --follow HEROKU_POSTGRESQL_CRIMSON_URL --app touchcard

heroku maintenance:on -a appname

heroku pg:promote HEROKU_POSTGRESQL_AQUA

backup both DBs

 - BACKUP POINT: 05:30 UTC

promote from staging

heroku run rake db:migrate -a appname

heroku run rake cardsetup:card_side_to_json -a appname

change path in Shopify from `/app` to `/`

scale up dynos

maintenance off


    Misc:
    
    1. Upgrade Buildpacks using app.json
    
    
        heroku buildpacks -a touchcard-staging    
        heroku buildpacks:clear -a touchcard
        heroku buildpacks:add jontewks/puppeteer -a touchcard-staging
        heroku buildpacks:add heroku/nodejs -a touchcard-staging
        heroku buildpacks:add heroku/ruby -a touchcard-staging
    
    2. Upgrade Stack
        heroku stack:set heroku-18 -a touchcard-staging
        
    ## CRITICAL !!!
    heroku run rake cardsetup:card_side_to_json -a touchcard-staging

