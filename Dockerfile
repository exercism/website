FROM ruby:2.6.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y cmake nodejs yarn

RUN curl -L -o - https://github.com/DarthSim/hivemind/releases/download/v1.0.6/hivemind-v1.0.6-linux-arm64.gz | gunzip > /usr/local/bin/hivemind && \	
    chmod u+x /usr/local/bin/hivemind

RUN curl -L -o /usr/local/bin/anycable-go https://github.com/anycable/anycable-go/releases/download/v1.0.0/anycable-go-linux-amd64 && \
    chmod u+x /usr/local/bin/anycable-go

RUN gem install bundler

WORKDIR /usr/src/app

CMD ["sh", "docker/init.sh"]
