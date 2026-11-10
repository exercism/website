# This file runs Rails migrations with a retry guard
# for any concurrent failures;

begin
  # Offset all the different rails c's against each other over 30secs
  # Put it in this begin so it keeps on happening on each retry.
  sleep(rand * 30)

  # Since Rails 7.2 the migration context, schema migration and internal
  # metadata live on the connection pool rather than on the connection.
  pool = ActiveRecord::Base.connection_pool
  ActiveRecord::Migrator.new(
    :up,
    pool.migration_context.migrations,
    pool.schema_migration,
    pool.internal_metadata
  ).migrate

  Rails.logger.info "Migrations ran cleanly"
rescue ActiveRecord::ConcurrentMigrationError
  # If another service is running the migrations, then
  # we wait until it's finished. There's no timeout here
  # because eventually Fargate will just time the machine out.

  Rails.logger.info "Concurrent migration detected. Waiting to try again."
  retry
end
