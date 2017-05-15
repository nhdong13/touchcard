# Changelog

## Master (unreleased)

- Track coupons even if they weren't entered as upper case 
- Update oauth scopes. Remove unneeded writes, Add price rules and marketing events.  
- Make S3 filename sanitization more robust
- Fix price filtering to use total_price instead of total_line_items_price
- Update shopify_app gem and handle webhooks with active job

 
## v1.1.9

- Strip `(` and `)` from S3 filenames to prevent blank postcards 