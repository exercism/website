FROM ruby:2.6.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && \
    apt-get install -y cmake yarn

# Install hivemind
RUN curl -L -o - https://github.com/DarthSim/hivemind/releases/download/v1.0.6/hivemind-v1.0.6-linux-arm64.gz | \
    gunzip > /usr/local/bin/hivemind && \
    chmod u+x /usr/local/bin/hivemind

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock package.json yarn.lock ./

RUN yarn install && \
    gem install bundler && \
    bundle install

CMD ["hivemind", "-p", "3000", "./Procfile.dev"]