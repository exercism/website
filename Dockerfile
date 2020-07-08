FROM ruby:2.6.6-alpine3.12

RUN gem install bundler && \
    apk add --no-cache --update build-base cmake git libc6-compat mysql-dev nodejs tzdata yarn && \
    wget https://github.com/DarthSim/hivemind/releases/download/v1.0.6/hivemind-v1.0.6-linux-arm64.gz -O - | \gunzip > /usr/local/bin/hivemind && \
    wget https://github.com/anycable/anycable-go/releases/download/v1.0.0/anycable-go-linux-amd64 -O /usr/local/bin/anycable-go && \
    chmod u+x /usr/local/bin/hivemind && \
    chmod u+x /usr/local/bin/anycable-go

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install --check-files --update-checksums

CMD ["sh", "docker/init.sh"]
