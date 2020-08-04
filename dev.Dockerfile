# -------------------------------------------------------------------------------
# [stage 1] Build gems will full buildpack-deps
# -------------------------------------------------------------------------------
FROM ruby:2.6.6 as builder

RUN set -ex; \
    apt-get update; \
    apt-get install -y cmake;

RUN gem install -N bundler:2.1.4

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf /usr/local/bundle/bundler/gems/rails-*/.git/ && \
    rm -rf /usr/local/bundle/cache/bundler/git/

# -------------------------------------------------------------------------------
# [stage 2] Switch to slim build
# -------------------------------------------------------------------------------
FROM ruby:2.6.6-slim-buster

RUN set -ex; \
    apt-get update; \
    apt-get install -y curl gnupg; \
    rm -rf /var/lib/apt/lists/*

# node & yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs yarn tmux

# overmind
RUN curl -L -o - https://github.com/DarthSim/overmind/releases/download/v2.2.0/overmind-v2.2.0-linux-amd64.gz | gunzip > /usr/local/bin/overmind && \
    chmod u+x /usr/local/bin/overmind

# anycable
RUN curl -L -o /usr/local/bin/anycable-go https://github.com/anycable/anycable-go/releases/download/v1.0.0/anycable-go-linux-amd64 && \
    chmod u+x /usr/local/bin/anycable-go

# chrome, for headless tests
RUN curl -L -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./google-chrome-stable_current_amd64.deb && \
    rm ./google-chrome-stable_current_amd64.deb

RUN apt-get install -y libmariadb-dev git;

WORKDIR /usr/src/app

RUN gem install -N bundler:2.1.4

# copy over gems from build
COPY Gemfile Gemfile.lock ./
COPY --from=builder /usr/local/bundle /usr/local/bundle
RUN bundle list

COPY package.json yarn.lock ./
RUN yarn install && yarn cache clean;

CMD ["sh", "docker/init.dev.sh"]

# CMD ["/bin/bash"]