class AddNonUniqueUserForeignToCohortMemberships < ActiveRecord::Migration[7.0]
  def change
    add_index :cohort_memberships, :user_id, if_not_exists: true
    add_foreign_key :cohort_memberships, :users, column: :user_id    
  end
end
