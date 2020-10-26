FROM ruby:2.6.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y cmake nodejs yarn

WORKDIR /opt/exercism/website/current

# Set this as a global env var
ENV RAILS_ENV=production

# Only Gemfile and Gemfile.lock changs require a new bundle install
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle install

# Only package.json and yarn.lock require a new yarn install
COPY package.json yarn.lock ./
RUN yarn install

# Copy any files that might require an asset compilation changing.
# These are:
# - Anything in the apex (such as babel.config.js); and 
# - The bin directory that contains the requisit scripts
# - The config directory which controls webpacker settings
# - The contents on app/javascript
# These are deliberately permissive in case we want to add
# future apex files or future config files, so we don't have
# to worry about adding them here.

# TODO: If these can be merged into one that would save
# a lot of cache space
COPY *.js *.json ./
COPY bin ./bin
COPY config ./config
COPY app/javascript ./app/javascript
COPY app/css ./app/css

# This compiles the assets into public/packs
# During deployment the assets are copied from this image and 
# uploaded into s3. The assets left on the machine are not actually
# used leave the assets on here.
RUN RACK_ENV=production NODE_ENV=production bundle exec bin/webpack

# Copy everything over now
COPY . ./

ENTRYPOINT bin/start_webserver
