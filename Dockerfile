FROM ruby:2.6.6

# Install dependencies
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y cmake yarn && \
    curl -L -o - https://github.com/DarthSim/hivemind/releases/download/v1.0.6/hivemind-v1.0.6-linux-arm64.gz | gunzip > /usr/local/bin/hivemind && \
    curl -L -o /usr/local/bin/anycable-go https://github.com/anycable/anycable-go/releases/download/v1.0.0/anycable-go-linux-amd64 && \
    chmod u+x /usr/local/bin/hivemind && \
    chmod u+x /usr/local/bin/anycable-go && \
    gem install bundler

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install

CMD ["hivemind", "-p", "3000", "./Procfile.dev"]
