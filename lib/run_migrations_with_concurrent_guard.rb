# This file runs Rails migrations with a retry guard
# for any concurrent failures;

begin
  # Offset all the different rails c's against each other over 30secs
  # Put it in this begin so it keeps on happening on each retry.
  sleep(rand * 30)

  migrations = ActiveRecord::Migration.new.migration_context.migrations
  ActiveRecord::Migrator.new(:up, migrations, ActiveRecord::SchemaMigration).migrate

  Rails.logger.info "Migrations ran cleanly"
rescue ActiveRecord::ConcurrentMigrationError
  # If another service is running the migrations, then
  # we wait until it's finished. There's no timeout here
  # because eventually Fargate will just time the machine out.

  Rails.logger.info "Concurrent migration detected. Waiting to try again."
  retry
end
