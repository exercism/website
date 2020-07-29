bundle exec bin/create_dynamodb_config
bin/rails db:create
bin/rails db:migrate
bin/rails log:clear tmp:clear
bin/rails runner "scripts/setup_dynamodb_locally.rb"
hivemind -p 3020 ./Procfile.docker.dev
