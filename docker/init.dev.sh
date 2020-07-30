bundle update --full-index --conservative exercism_config
EXERCISM_DOCKER=true EXERCISM_ENV=development setup_exercism_config
bin/rails db:create
bin/rails db:migrate
bin/rails runner scripts/setup_aws_locally.rb
overmind start -p 3020 -f ./Procfile.docker.dev
