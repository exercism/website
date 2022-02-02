FROM ruby:3.1.0-bullseye

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y cmake make nodejs yarn graphicsmagick

WORKDIR /opt/exercism/website

# Set this as a global env var
ENV RAILS_ENV=production

# Only Gemfile and Gemfile.lock changes require a new bundle install
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
# - The contents on app/javascript
# These are deliberately permissive in case we want to add
# future apex files or future config files, so we don't have
# to worry about adding them here.

# This compiles the assets into public/packs
# During deployment the assets are copied from this image and 
# uploaded into s3. The assets left on the machine are not actually
# used leave the assets on here.
ENV NODE_OPTIONS="--max-old-space-size=6144"

# Copy everything over now
COPY . ./

RUN NODE_ENV=production bundle exec rails assets:precompile

ENTRYPOINT bin/start_webserver
