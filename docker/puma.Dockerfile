FROM ruby:2.6.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y cmake nodejs yarn

RUN gem install bundler
RUN bundle config set deployment 'true'
RUN bundle config set without 'development test'

WORKDIR /opt/exercism/website/current

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install

COPY . ./
RUN RAILS_ENV=production RACK_ENV=production NODE_ENV=production bundle exec bin/webpack

ENTRYPOINT bundle exec bin/rails server -e production -b '0.0.0.0' -p 3000
