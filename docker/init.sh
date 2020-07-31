RAILS_ENV=production bundle exec bin/rails db:create
RAILS_ENV=production bundle exec bin/rails db:migrate
overmind start -p 80 -f ./Procfile
