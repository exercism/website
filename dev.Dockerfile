#############
## Stage 1 ##
#############
FROM ruby:3.1.0-bullseye as builder

RUN set -ex; \
    apt-get update; \
    apt-get install -y cmake make ruby-dev

# We can do this work early and then copy a binary to the slim build later
# overmind
RUN curl -L -o - https://github.com/DarthSim/overmind/releases/download/v2.2.0/overmind-v2.2.0-linux-amd64.gz | gunzip > /usr/local/bin/overmind && \
    chmod u+x /usr/local/bin/overmind

# anycable
RUN curl -L -o /usr/local/bin/anycable-go https://github.com/anycable/anycable-go/releases/download/v1.0.0/anycable-go-linux-amd64 && \
    chmod u+x /usr/local/bin/anycable-go

RUN gem install -N bundler:2.3.4

#############
## Stage 2 ##
#############
FROM ruby:3.1.0-slim-bullseye as slim-website

RUN set -ex; \
    apt-get update; \
    # we need the mysql client for our init script to setup the databases
    # git is required for `jest --watch`
    apt-get install -y curl gnupg default-mysql-client git gcc libvips42; \
    rm -rf /var/lib/apt/lists/*

# copy over anycable and overmind
COPY --from=builder  /usr/local/bin/overmind /usr/local/bin/overmind
COPY --from=builder  /usr/local/bin/anycable-go /usr/local/bin/anycable-go

# node & yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs yarn tmux

# graphicsmagick
RUN apt-get install -y graphicsmagick

# chrome, for headless tests
RUN DEBIAN_FRONTEND=noninteractive && \
    curl -L -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm ./google-chrome-stable_current_amd64.deb

RUN apt-get install -y libmariadb-dev git;

WORKDIR /usr/src/app

RUN gem install -N bundler:2.3.4

#############
## Stage 3 ##
#############
FROM builder as gembuilder

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf /usr/local/bundle/bundler/gems/rails-*/.git/ && \
    rm -rf /usr/local/bundle/cache/bundler/git/

#############
## Stage 4 ##
#############
FROM slim-website

# copy over gems from build
COPY Gemfile Gemfile.lock ./
COPY --from=gembuilder /usr/local/bundle /usr/local/bundle

COPY package.json yarn.lock ./
RUN yarn install && yarn cache clean

WORKDIR /usr/src/app
COPY . .

CMD ["sh", "docker/dev/init.dev.sh"]
