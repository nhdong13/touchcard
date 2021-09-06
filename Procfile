release: bundle exec rails db:migrate
webpacker: yarn install && ./bin/webpack --watch --progress --colors
web: bundle exec puma -C config/puma.rb -p $PORT
worker: bundle exec rails jobs:work
