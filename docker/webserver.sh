#!/bin/bash

# TODO: Remove the reset and the seed once we're in the beta
RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec bin/rails db:migrate:reset db:seed

bundle exec bin/rails server -e production -b '0.0.0.0' -p 3000
