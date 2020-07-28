server:      RAILS_LOG_TO_STDOUT=true bundle exec bin/rails server -e production -b '0.0.0.0' -p 80
anycable-go: RAILS_LOG_TO_STDOUT=true bundle exec bin/rails runner -e production "exec(\"anycable-go --host=0.0.0.0 --port 3334 --redis_url='#{Exercism.config.anycable_endpoint}'\")"
anycable:    bundle exec anycable
