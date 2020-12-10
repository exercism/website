class AddUserReputation < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :reputation, :integer, null: false, default: 0
  end
end
