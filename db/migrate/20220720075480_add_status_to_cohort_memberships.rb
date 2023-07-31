class AddStatusToCohortMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :cohort_memberships, :status, :tinyint, default: 0, null: false, if_not_exists: true
  end
end
