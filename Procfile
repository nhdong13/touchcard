release: bundle exec rails db:migrate
web: bundle exec puma -C config/puma.rb -p $PORT
worker: bundle exec rails jobs:work
