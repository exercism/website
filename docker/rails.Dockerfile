FROM ruby:3.2.1-bullseye

ARG GEOIP_LICENSE_KEY
ARG GEOIP_CACHE_BUSTER
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=6144"

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y cmake make nodejs yarn graphicsmagick libvips42

WORKDIR /usr/share/GeoIP

RUN curl "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${GEOIP_LICENSE_KEY}&suffix=tar.gz" --output geolite2-city.tar.gz && \
    tar -xvf geolite2-city.tar.gz --strip-components=1 --wildcards '*/GeoLite2-City.mmdb' && \
    rm geolite2-city.tar.gz

WORKDIR /opt/exercism/website

RUN gem install nokogiri -v 1.14.2 && \
    gem install propshaft -v 0.4.0 && \
    gem install anycable -v 1.2.5 && \
    gem install bundler -v 2.4.13

# Only Gemfile and Gemfile.lock changes require a new bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle install

# Only package.json and yarn.lock changes require a new yarn install
COPY package.json yarn.lock ./
RUN yarn install

# Copy everything over now
COPY . ./

# Speed things up by precompiling bootsnap
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# This compiles the assets
# During deployment the assets are copied from this image and
# uploaded into s3. The assets left on the machine are not actually
# used leave the assets on here.
RUN bundle exec rails r bin/monitor-manifest
RUN bundle exec rails assets:precompile

RUN groupadd -g 2222 exercism-git
RUN usermod -a -G exercism-git root

ENTRYPOINT bin/start_webserver
