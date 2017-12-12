source "https://rubygems.org"

#ruby=2.4.2
#ruby-gemset=touchcard

ruby "2.4.2"

gem "rails", "5.1.4"
gem "rake", "~> 12.3.0"
gem "rb-readline", "~> 0.5.3"

# # Add material design lite for CSS
gem 'material_components_web-sass'


gem "sass-rails", "~> 5.0", ">= 5.0.6"
gem "uglifier", ">= 1.3.0"


gem "turbolinks"
gem "sdoc", "~> 0.4.0", group: :doc

# Admin interface
gem "devise", "~> 4.3.0"
gem "activeadmin", "~> 1.0.0"
gem "active_material", git: "https://github.com/laverick/active_material"

# API serializer
gem "active_model_serializers", "~> 0.8.0"

# Shopify app
gem "shopify_app", "~> 7.3.0"

# Stripe
gem 'stripe', git: 'https://github.com/stripe/stripe-ruby'

# S3 connection
gem "aws-sdk", "~> 2.1"

# Image Manipulation
gem "rmagick", "~> 2.15"

# Lob integration
gem "lob", "~> 2.1"

# Key Value store
gem "redis", "~> 3.2"

# Httparty for debug
gem "httparty", "~> 0.13"

# Rest Client for Slack notifications
gem "rest-client", "1.8"

# Use Unicorn as the app server
gem "unicorn", "~> 4.9"

# Background tasks
gem "delayed_job_active_record", "~> 4.1.2"
gem "daemons", "~> 1.2"

# Better rails console
gem "wirble", "~> 0.1"
gem "hirb", "~> 0.7"

# calculate business days
gem "business_time", "~> 0.7"

# send mails using mailgun
gem "mailgunner", '~> 2.4'

# ActiveCampaign ('bdad6c2' is last building version as of 2017-08-26)
gem "active_campaign", git: "https://github.com/laverick/active_campaign", ref: "bdad6c2"

gem 'faker'

# Javascript Pipeline
gem "webpacker", "~> 3.0"

# For running server processes in development
gem "foreman", "~> 0.84"
gem "thor", "~> 0.19.1"

gem "pg"

group :assets do
  gem "therubyracer", platforms: :ruby
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console", "~> 2.0"
  gem "thin", "~> 1.7.2"
  gem "spring"
end

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem "clipboard", "~> 1.0"
  gem 'simplecov', :require => false
end

group :test do
  gem "rspec-rails", "~> 3.6.0"
  gem "factory_girl_rails", "~> 4.5"
  gem "webmock", "~> 1.22"
end

group :production do
  gem "newrelic_rpm", "~> 3.15"
end
