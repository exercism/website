bundle install
yarn install --check-files
bin/rails db:create
bin/rails db:migrate
hivemind -p 3020 ./Procfile.docker.dev
