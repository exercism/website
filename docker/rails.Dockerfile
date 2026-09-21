FROM ruby:3.4.4-bookworm AS build

ARG BUNDLER_VERSION
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=6144"
ENV NODE_MAJOR=22

RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/yarn.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y cmake make nodejs yarn graphicsmagick libvips42

WORKDIR /opt/exercism/website

ENV BUNDLE_PATH=/usr/local/bundle
ENV GEM_HOME=$BUNDLE_PATH
ENV GEM_PATH=$BUNDLE_PATH
ENV PATH=$BUNDLE_PATH/bin:$PATH
RUN gem install bundler -v "${BUNDLER_VERSION}"

RUN bundle config set frozen 'true' && \
    bundle config set without 'development test' && \
    bundle config set path "${BUNDLE_PATH}"

RUN gem install propshaft -v 0.4.0 --no-document --install-dir=$BUNDLE_PATH
RUN gem install nokogiri -v 1.18.8 --no-document --install-dir=$BUNDLE_PATH
RUN gem install anycable -v 1.6.0 --no-document --install-dir=$BUNDLE_PATH
RUN gem install oj -v 3.14.3 --no-document --install-dir=$BUNDLE_PATH
RUN gem install rugged -v 1.9.0 --no-document --install-dir=$BUNDLE_PATH
RUN gem install mysql2 -v 0.5.6 --no-document --install-dir=$BUNDLE_PATH
RUN gem install commonmarker -v 0.23.8 --no-document --install-dir=$BUNDLE_PATH
RUN gem install grpc -v 1.73.0 --no-document --install-dir=$BUNDLE_PATH
RUN gem install devise -v 4.9.4 --no-document --install-dir=$BUNDLE_PATH

# Only Gemfile and Gemfile.lock changes require a new bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install

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
#
# EXERCISM_IMAGE_BUILD boots the app without AWS (see config/image_build.rb),
# and these two public values are the only config that ends up in the assets.
ARG WEBSITE_ASSETS_HOST
ARG SENTRY_JS_DSN
RUN EXERCISM_IMAGE_BUILD=1 bundle exec rails r bin/monitor-manifest
RUN EXERCISM_IMAGE_BUILD=1 bundle exec rails assets:precompile
RUN bin/cleanup-css

# Deployment uploads the compiled assets to S3. They come out of here as a
# filesystem export of this stage, so extracting them never has to load the
# multi-gigabyte image into a Docker daemon first. Kept above `runtime` so the
# default build target is still the image we ship.
FROM scratch AS assets
COPY --from=build /opt/exercism/website/public/assets /

FROM ruby:3.4.4-bookworm AS runtime

ENV RAILS_ENV=production
ENV NODE_ENV=production

RUN apt-get update && \
    apt-get install -y graphicsmagick libvips42

RUN groupadd -g 2222 exercism-git
RUN usermod -a -G exercism-git root

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /opt/exercism/website /opt/exercism/website

WORKDIR /opt/exercism/website

ENV BUNDLE_PATH=/usr/local/bundle
RUN bundle config set frozen 'true' && \
    bundle config set without 'development test' && \
    bundle config set path "${BUNDLE_PATH}" && \
    bundle check

ENTRYPOINT bin/start_webserver
