while ! mysqladmin ping -h"$DB_HOST" --silent; do
    echo "Waiting on MySQL..."
    sleep 2
done

echo "Create and migrate DBs"
# init.sql creates initial MySQL USER and databases
mysql -u root -ppassword -h "$DB_HOST" < docker/dev/init.sql
bundle exec bin/rails db:migrate

echo "Start up the website stack"
overmind start -p 3020 -s /usr/src/app/tmp/overmind.sock -f ./Procfile.docker.dev
