require "test_helper"

class MigrationsTest < ActiveSupport::TestCase
  test "don't modify tables in production" do
    ApplicationRecord.connection.migration_context.migrations.each do |migration_proxy|
      # We only started running migrations manually after the below time
      next if migration_proxy.version <= 20231103102049 # rubocop:disable Style/NumericLiterals

      migration = File.read(migration_proxy.filename)
      assert_includes migration, "return if Rails.env.production?"
    end
  end
end
