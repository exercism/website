class DropCohorts < ActiveRecord::Migration[7.1]
  def up
    return if Rails.env.production?

    drop_table :cohort_memberships
    drop_table :cohorts
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
