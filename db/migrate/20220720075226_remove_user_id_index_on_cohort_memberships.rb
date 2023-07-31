class RemoveUserIdIndexOnCohortMemberships < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :cohort_memberships, :users, column: :user_id
    remove_index :cohort_memberships, :user_id, if_not_exists: true
  end
end
