
1. Upgrade Buildpacks using app.json


    heroku buildpacks -a touchcard-staging    
    heroku buildpacks:clear -a touchcard
    heroku buildpacks:add jontewks/puppeteer -a touchcard-staging
    heroku buildpacks:add heroku/nodejs -a touchcard-staging
    heroku buildpacks:add heroku/ruby -a touchcard-staging

2. Upgrade Stack


    heroku stack:set heroku-18 -a touchcard-staging
    
    
push / deploy


heroku run rake db:migrate



heroku run rake db:cardsetup -a touchcard-staging


Change path in Shopify from `/app` to `/`
