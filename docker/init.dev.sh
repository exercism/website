bin/rails db:create
bin/rails db:migrate
bin/create_dynamodb_config
bin/rails log:clear tmp:clear
hivemind -p 3020 ./Procfile.docker.dev
