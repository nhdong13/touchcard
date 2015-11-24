source "https://rubygems.org"

#ruby=2.2.0
#ruby-gemset=touchcard

ruby "2.2.0"

gem "rails", "4.2.4"

gem "bootstrap-sass"

gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.1.0"

gem "jquery-rails"
gem "momentjs-rails", ">= 2.8.1"
gem "turbolinks"
gem "jbuilder", "~> 2.0"
gem "sdoc", "~> 0.4.0", group: :doc

# Admin interface
gem "devise"
gem "activeadmin", github: "activeadmin"

# API serializer
gem "active_model_serializers", "~> 0.8.0"

# Shopify app
gem "shopify_app"

# Stripe
gem 'stripe', git: 'https://github.com/stripe/stripe-ruby'

# S3 connection
gem "aws-sdk"

# Card creator ui js
gem "jquery-ui-rails"

# Image Manipulation
gem "rmagick"

# Lob integration
gem "lob"

# Newrelic for monitoring
#gem "newrelic_rpm"

# Key Value store
gem "redis"

# Httparty for debug
gem "httparty"

# Rest Client for Slack notifications
gem "rest-client"

# Use Unicorn as the app server
gem "unicorn"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

# Background tasks
gem "delayed_job_active_record"
gem "daemons"

# Better rails console
gem "wirble"
gem "hirb"

group :assets do
  gem "therubyracer", platforms: :ruby
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console", "~> 2.0"
  gem "thin"
  gem "spring"
end

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem "sqlite3"
  gem "less-rails-bootstrap"
  gem "rspec-rails", "~> 3.0"
  gem "factory_girl_rails"
  # gem "webmock"
end

group :production do
  gem "pg"
  gem "rails_12factor"
end
