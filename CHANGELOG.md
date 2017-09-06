# Changelog

## (UNRELEASED)
- Comprehensive Admin Tool Improvements: 
    - Navigation 
    - Edit: Subscription Quantity, Shop Credits, Card Order Sending Enable
    - Cancel Postcards
- Add name and size tag to ActiveCampaign subscribers
- Add subscribers to Customer list in ActiveCampaign
- Background task install jobs (ActiveCampaign Subscribe + Slack Notify)
- Bump default send_delay to 1 week
- Add Data Importer Library (not yet hooked up)


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