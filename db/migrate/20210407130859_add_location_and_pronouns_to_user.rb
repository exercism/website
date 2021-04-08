class AddLocationAndPronounsToUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :user_profiles, :location
    add_column :users, :location, :string, null: true
    add_column :users, :pronouns, :string, null: true
  end
end
