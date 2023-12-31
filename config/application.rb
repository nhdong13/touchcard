require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Touchcard
  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add delayed_job
    config.active_job.queue_adapter = :delayed_job

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # TODO Check why this throws error for Rails 5.1.x
    # config.active_record.raise_in_transactional_callbacks = true
    # config.force_ssl = true

    # Gzip pages by default, see: https://www.schneems.com/2017/11/08/80-smaller-rails-footprint-with-rack-deflate/
    config.middleware.insert_after ActionDispatch::Static, Rack::Deflater

  end
end
