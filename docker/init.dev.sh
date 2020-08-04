echo "Create and migrate DBs"
bundle exec bin/rails db:create
bundle exec bin/rails db:migrate

echo "Set up local AWS"
overmind start -p 3020 -s /usr/src/app/tmp/overmind.sock -f ./Procfile.docker.dev
