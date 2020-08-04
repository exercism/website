# echo "Install bundler stuff"
# bundle update --full-index --conservative exercism_config

# echo "Setup Exercism Config"
# bundle exec setup_exercism_config

echo "Create and migrate DBs"
bundle exec bin/rails db:create db:migrate

echo "Set up local AWS"
# bundle exec bin/rails runner scripts/setup_aws_locally.rb
overmind start -p 3020 -s /usr/src/app/tmp/overmind.sock -f ./Procfile.docker.dev
