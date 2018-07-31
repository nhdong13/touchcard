# Changelog
#

## (unreleased)
- CHANGES:
    - ...
    - Add abandoned_checkouts rake task. (Can be set up as scheduled task, but will save this for now.)

- RELEASE REQUIREMENTS

    - Upgrade stack: `heroku-16`
    - Upgrade Database to Pro
    - ENV: removed AWS_BUCKET_NAME, only using S3_BUCKET_NAME
    - ENV: add GTM_ENVIRONMENT_PARAMS (see gtm_helper.rb)
        - DEV: '&gtm_auth=n553XLcYVrmY05MZ2RjQyA&gtm_preview=env-5&gtm_cookies_win=x' 
        - LIVE: '&gtm_auth=Vu4BC2LBqiawRiIX2VOn4g&gtm_preview=env-2&gtm_cookies_win=x'
    - ENV: REAMAZE_SSO_SECRET    
    - BUILDPACKS - see README for required buildpacks    
     

## v1.2.10
- Remove future send_date from Admin tool's sample postcard dispatcher. New API plans don't support it.

## v1.2.9
- Fix app re-install (make sure that all Shops have correct value for uninstalled_at)

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
