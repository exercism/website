FROM ruby:2.6.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y cmake nodejs yarn

WORKDIR /opt/exercism/website/current

# Only Gemfile and Gemfile.lock changs require a new bundle install
RUN gem install bundler
RUN bundle config set deployment 'true'
RUN bundle config set without 'development test'
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Only package.json and yarn.lock require a new yarn install
COPY package.json yarn.lock ./
RUN yarn install

# Copy any files that might require an asset compilation changing.
# These are anything in the apex (such as babel.config.js); and 
# the contents on app/javascript
# Otherwise we can cache this layer.
COPY * ./
COPY app/javascript ./app/javascript
RUN RAILS_ENV=production RACK_ENV=production NODE_ENV=production bundle exec bin/webpack

ENTRYPOINT RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec bin/rails db:migrate:reset db:seed && bundle exec bin/rails server -e production -b '0.0.0.0' -p 3000
