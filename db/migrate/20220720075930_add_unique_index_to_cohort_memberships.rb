class AddUniqueIndexToCohortMemberships < ActiveRecord::Migration[7.0]
  def change
    add_index :cohort_memberships, %i[user_id cohort_id], unique: true
  end
end
