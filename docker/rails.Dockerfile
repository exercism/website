FROM ruby:3.1.0-bullseye

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y cmake make nodejs yarn graphicsmagick

WORKDIR /opt/exercism/website

ENV RAILS_ENV=production

# Only Gemfile and Gemfile.lock changes require a new bundle install
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle install

# Temporarily set the node environment to development to 
# also install devDependencies (which are used to compile
# the assets later on)
ENV NODE_ENV=development
ENV NODE_OPTIONS="--max-old-space-size=6144"

# Only package.json and yarn.lock changes require a new yarn install
COPY package.json yarn.lock ./
RUN yarn install

# Copy everything over now
COPY . ./

# This compiles the assets
# During deployment the assets are copied from this image and 
# uploaded into s3. The assets left on the machine are not actually
# used leave the assets on here.
RUN bundle exec rails r bin/monitor-manifest
RUN EXERCISM_DEPLOY=true bundle exec rails assets:precompile

# Re-enable production mode, which enables things like React
# production mode
ENV NODE_ENV=production

ENTRYPOINT bin/start_webserver
