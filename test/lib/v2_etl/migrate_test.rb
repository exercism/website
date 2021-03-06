# Run with:
# rake db:migrate:reset; rails test test/lib/v2_etl/migrate_test.rb

require "test_helper"
# require_relative '../../../lib/v2_etl/migrate'

# Some times this gets into a mess. In that situation it's best to drop
# the exercism_v3_test database entirely and recreate it (see README)

module V2ETL
  class MigrateTest < ActiveSupport::TestCase
    def test_everything
      # Check we can still create all the factories
      FactoryBot.factories.map(&:name).each do |factory|
        # Run each in isolation
        ActiveRecord::Base.transaction do
          create factory
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
