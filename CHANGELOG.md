# Changelog


## (in development)
- ...
- ENV
    - Removed AWS_BUCKET_NAME, only using S3_BUCKET_NAME
    - add GTM_ENVIRONMENT_PARAMS (see gtm_helper.rb)
    
- DEPLOYMENT    
    heroku buildpacks:add https://github.com/heroku/heroku-buildpack-google-chrome.git
    heroku buildpacks:add https://github.com/heroku/heroku-buildpack-chromedriver.git
    
    ### looks like nodejs buildpack is still required as well.
    
    
    Chrome Buildpack
    https://github.com/heroku/heroku-buildpack-google-chrome/issues/26
     

## v1.2.8
- Hotfix 
    - new last_month calculation was wrong because we were only counting open orders
    - postcards/index api was sorting by updated_at. changed to created_at to be less confusing
    - added missing include in uninstalled job

## v1.2.7
- Hotfix - New way of checking ShopifyAPI::Customer.default_address in orders/create webhook was broken. 


## v1.2.6
- Comprehensive Admin Tool Improvements: 
    - Navigation 
    - Edit: Subscription Quantity, Shop Credits, Card Order Sending Enable
    - Send Sample Postcard
    - Cancel Postcards
    - Material Design Skin    
- Add name and size tag to ActiveCampaign subscribers
- Add subscribers to Customer list in ActiveCampaign
- Background task install jobs (ActiveCampaign Subscribe + Slack Notify)
- Bump default send_delay to 1 week
- Add Data Importer Library (not yet hooked up)
- Cap last_month value to # orders in case of import. (+remove synchronous call from install)


## v1.2.3
- Add Ember Metrics for Google Tag Manager & Intercom ('booted' in GTM)

## v1.2.2
- Get ActiveAdmin working (internal admin panel). 

## v1.2.1

- Change from Discounts API to Price Rules API (db:migrate + rake price_rules:make_discounts_negative)

Deployment:
    db:migrate 
    rake price_rules:make_discounts_negative
    deploy matching client v1.2.0

## v1.1.10

- Track coupons even if they weren't entered as upper case 
- Update oauth scopes. Remove unneeded writes, write_price_rules and write_marketing_events.  
- Make S3 filename sanitization more robust
- Fix price filtering to use total_price instead of total_line_items_price
- Update shopify_app gem and handle webhooks with active job


## v1.1.9

- Strip `(` and `)` from S3 filenames to prevent blank postcards 
