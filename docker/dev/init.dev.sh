while ! mysqladmin ping -h"$DB_HOST" --silent; do
    echo "Waiting on MySQL..."
    sleep 2
done

echo "Install dependencies"
bundle check || bundle install
yarn install

echo "Create and migrate DBs"
# init.sql creates initial MySQL USER and databases
mysql -u root -ppassword -h "$DB_HOST" < docker/dev/init.sql
bundle exec bin/rails db:migrate

num_users=$(bundle exec rails r "p User.count" 2>/dev/null)
echo "${num_users} user(s) found."
if [ "${num_users}" -eq 0 ]; then
    echo "Reseeding..."
    bundle exec bin/rails db:seed
fi

echo "Start up the website stack"
overmind start -p 3020 -s /usr/src/app/tmp/overmind.sock -f ./Procfile.docker.dev
