# This file runs Rails migrations with a retry guard
# for any concurrent failures;

begin
  migrations = ActiveRecord::Migration.new.migration_context.migrations
  ActiveRecord::Migrator.new(:up, migrations, ActiveRecord::SchemaMigration).migrate
  puts "Migrations ran cleanly"
rescue ActiveRecord::ConcurrentMigrationError
  # If another service is running the migrations, then
  # we wait until it's finished. There's no timeout here
  # because eventually Fargate will just time the machine out.

  puts "Concurrent migration detected. Waiting to try again."
  sleep(5)
  retry
end
