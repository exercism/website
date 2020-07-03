bundle install &&
bundle exec bin/rails db:create &&
bundle exec bin/rails db:migrate &&
yarn install &&
hivemind -p 3000 ./Procfile.docker.dev
