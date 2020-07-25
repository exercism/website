RAILS_ENV=production bin/rails db:create
RAILS_ENV=production bin/rails db:migrate
hivemind -p 80 ./Procfile
