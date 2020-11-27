class AddAcceptFieldsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :accepted_privacy_policy_at, :datetime
    add_column :users, :accepted_terms_at, :datetime
  end
end
