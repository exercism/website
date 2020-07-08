bin/rails db:create
bin/rails db:migrate
hivemind -p 3000 ./Procfile.docker.dev
