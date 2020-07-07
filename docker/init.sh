yarn install --check-files
bundle exec bin/rails db:create
bundle exec bin/rails db:migrate
hivemind -p 3000 ./Procfile.docker.dev
