setup_exercism_config --settings-file=/usr/src/settings/settings.yml
bin/rails db:create
bin/rails db:migrate
bin/rails runner scripts/setup_dynamodb_locally.rb
hivemind -p 3020 ./Procfile.docker.dev
