FROM ruby:3.3.0-bullseye AS build

ARG GEOIP_ACCOUNT_ID
ARG GEOIP_LICENSE_KEY
ARG GEOIP_CACHE_BUSTER
ARG BUNDLER_VERSION
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=6144"
ENV NODE_MAJOR=20

RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y cmake make nodejs yarn graphicsmagick libvips42

WORKDIR /opt/exercism/website

RUN gem install bundler -v "${BUNDLER_VERSION}"

RUN bundle config set frozen 'true' && \
    bundle config set without 'development test'

RUN gem install propshaft -v 0.4.0
RUN gem install nokogiri -v 1.15.4
RUN gem install anycable -v 1.2.5
RUN gem install oj -v 3.14.2
RUN gem install rugged -v 1.6.3

# Only Gemfile and Gemfile.lock changes require a new bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    grpc_path="$(bundle show --paths grpc)/src/ruby/ext/grpc" && \
    make -C "${grpc_path}" clean && \
    rm -rf "${grpc_path}/libs" "${grpc_path}/objs"

# Only package.json and yarn.lock changes require a new yarn install
COPY package.json yarn.lock ./
RUN yarn install

# Pause to download GeoIP
WORKDIR /usr/share/GeoIP
RUN curl -J -L -u "${GEOIP_ACCOUNT_ID}:${GEOIP_LICENSE_KEY}" --output geolite2-city.tar.gz 'https://download.maxmind.com/geoip/databases/GeoLite2-City/download?suffix=tar.gz' && \
    tar -xvf geolite2-city.tar.gz --strip-components=1 --wildcards '*/GeoLite2-City.mmdb' && \
    rm geolite2-city.tar.gz

# Copy everything over now
WORKDIR /opt/exercism/website
COPY . ./

# Speed things up by precompiling bootsnap
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# This compiles the assets
# During deployment the assets are copied from this image and
# uploaded into s3. The assets left on the machine are not actually
# used leave the assets on here.
RUN bundle exec rails r bin/monitor-manifest
RUN bundle exec rails assets:precompile
RUN bin/cleanup-css

FROM ruby:3.3.0-bullseye AS runtime

ENV RAILS_ENV=production
ENV NODE_ENV=production

RUN apt-get update && \
    apt-get install -y graphicsmagick libvips42

RUN groupadd -g 2222 exercism-git
RUN usermod -a -G exercism-git root

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /opt/exercism/website /opt/exercism/website
COPY --from=build /usr/share/GeoIP /usr/share/GeoIP

WORKDIR /opt/exercism/website

RUN bundle config set frozen 'true' && \
    bundle config set without 'development test' && \
    bundle check

ENTRYPOINT bin/start_webserver
