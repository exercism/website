FROM ruby:2.6.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y cmake nodejs yarn tmux

RUN curl -L -o - https://github.com/DarthSim/overmind/releases/download/v2.2.0/overmind-v2.2.0-linux-amd64.gz | gunzip > /usr/local/bin/overmind && \	
    chmod u+x /usr/local/bin/overmind

RUN curl -L -o /usr/local/bin/anycable-go https://github.com/anycable/anycable-go/releases/download/v1.0.0/anycable-go-linux-amd64 && \
    chmod u+x /usr/local/bin/anycable-go

RUN gem install bundler
RUN bundle config set deployment 'true'
RUN bundle config set without 'development test'

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install

COPY . ./

CMD ["sh", "docker/init.sh"]
