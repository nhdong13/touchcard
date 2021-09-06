release: bundle exec rails db:migrate
webpacker: ./bin/webpack --watch --progress --colors
web: bundle exec puma -p $PORT -C config/puma.rb
worker: bundle exec rails jobs:work
