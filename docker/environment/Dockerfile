# Derived from https://github.com/nbulaj/ruby-chromedriver

FROM ruby:2.4.4

ENV DEBIAN_FRONTEND noninteractive
ENV CHROMIUM_DRIVER_VERSION 2.39

# Fetch newer Node version
RUN curl -s: https://deb.nodesource.com/setup_8.x | bash -

# Fetch newer Yarn version
RUN curl -s http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install dependencies & Chrome
# Not sure we actually need `xvfb` and dependencies
RUN apt-get update && apt-get -y --no-install-recommends install zlib1g-dev liblzma-dev wget xvfb unzip libgconf2-4 libnss3 nodejs yarn \
 && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -  \
 && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
 && apt-get update && apt-get -y --no-install-recommends install google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

# Install Chrome driver
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$CHROMIUM_DRIVER_VERSION/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver.zip chromedriver -d /usr/bin/ \
    && rm /tmp/chromedriver.zip \
    && chmod ugo+rx /usr/bin/chromedriver

#RUN apt-get update -qq && apt-get install -y --no-install-recommends apt-utils\
#    build-essential

WORKDIR /tmp

# Install fonts for rendering
# see: https://github.com/laverick/docker-xelatex/blob/master/Dockerfile
RUN git clone https://gitlab.com/touchcard/fonts/ fonts
RUN mkdir -p /usr/share/fonts/truetype/google-fonts/
RUN find $PWD/fonts/ -name "*.ttf" -exec install -m644 {} /usr/share/fonts/truetype/google-fonts/ \; || return 1
RUN rm -rf fonts
RUN fc-cache -f -v


# Install Ruby Gems
# Installing gems here ensures that the majority of gems are cached
# Users of this container should still `bundle install`
COPY Gemfile Gemfile.lock /tmp/
RUN bundle install


# Install Node Packages via Yarn (caching optimization)
# Users of this container should still `yarn`
COPY package.json yarn.lock /tmp/
RUN yarn install --pure-lockfile
#RUN yarn install --pure-lockfile --modules-folder /usr/local/node_modules/


# ENTRYPOINT: For example see https://github.com/nbulaj/ruby-chromedriver
