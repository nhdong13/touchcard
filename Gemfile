source 'https://rubygems.org'

#ruby=2.2.0
#ruby-gemset=touchcard

ruby '2.2.0'

gem 'rails', '4.2.4'

gem 'bootstrap-sass'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

# db foreign keys
gem 'foreigner'

# Admin interface
gem 'devise'
gem 'activeadmin', github: 'activeadmin'

# Shopify app
gem 'shopify_app'

# S3 connection
gem 'aws-sdk'

# Card creator ui js
gem 'jquery-ui-rails'

# Image Manipulation
gem 'rmagick'

# Lob integration
gem 'lob'

# Newrelic for monitoring
gem 'newrelic_rpm'

# Httparty for debug
gem 'httparty'

# Rest Client for Slack notifications
gem 'rest-client'

# Use Unicorn as the app server
gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'momentjs-rails', '>= 2.8.1'

# Background tasks
gem 'delayed_job_active_record'
gem 'daemons'

# Better rails console
gem 'wirble'
gem 'hirb'

group :assets do
  gem "therubyracer", platforms: :ruby
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'thin'
  gem 'spring'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'sqlite3'
  gem "less-rails-bootstrap"
end

group :production do
  gem "pg"
  gem "rails_12factor"
end
