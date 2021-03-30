source "https://rubygems.org"

#ruby=2.4.4
#ruby-gemset=touchcard

ruby "3.0.0"

gem "rails", "6.1.3"
gem "rake", "~> 12.3.0"
gem "rb-readline", "~> 0.5.3"

gem 'material_components_web-sass'

gem "sass-rails", "~> 5.0", ">= 5.0.6"
gem "uglifier", "~> 4.2"

gem 'coffee-rails', '~> 5.0.0'
gem "turbolinks"
gem "sdoc", "~> 2.0.4", group: :doc

# Admin interface
gem "devise", "~> 4.7"
gem "activeadmin", "~> 2.9"
gem "active_material", git: "https://github.com/laverick/active_material"
gem "json", "~> 2.5.1"
# Shopify app
gem "shopify_app", "~> 12.0.7"

# Stripe
gem 'stripe', '~> 5.30'

# S3 connection
gem "aws-sdk", "~> 2.1"

# Image Manipulation
gem "rmagick", "~> 2.15"

# Lob integration
gem "lob", "~> 5.0"

# Key Value store
gem "redis", "~> 3.2"

# Httparty for debug
gem "httparty", "~> 0.15"

# Rest Client for Slack notifications
gem "rest-client", "~> 2.0"

# Use Unicorn as the app server
gem "unicorn", "~> 4.9"

# Background tasks
gem "delayed_job_active_record", "~> 4.1.4"
gem "daemons", "~> 1.2"

# Better rails console
gem "wirble", "~> 0.1"
gem "hirb", "~> 0.7"

# calculate business days
gem "business_time", "~> 0.7"

# send mails using mailgun
gem "mailgunner", '~> 2.4'

gem "active_campaign", "0.1.16"

gem 'faker'

# Javascript Pipeline
gem "webpacker", "~> 3.0"

# For running server processes in development
gem "foreman", "~> 0.84"
gem "thor", "~> 1.1.0"

gem "pg"
gem "newrelic_rpm", "~> 6.15"
gem "selenium-webdriver"
gem 'bootstrap-datepicker-rails', '~> 1.9', '>= 1.9.0.1'
gem 'carrierwave', '~> 2.2'
gem "fog-aws"
gem "nokogiri", "~> 1.11.2"
gem "mimemagic", "0.3.7"
gem "webrick"

group :assets do
  gem "therubyracer", platforms: :ruby
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console"
  gem "thin"
  gem "spring"
end

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem 'simplecov', :require => false
end

group :test do
  gem "rspec-rails", "~> 3.7"
  gem "factory_bot", "~> 4.8"
  gem "webmock"
  gem "timecop"
end

group :production do
end
