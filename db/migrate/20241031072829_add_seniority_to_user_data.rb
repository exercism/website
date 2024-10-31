class AddSeniorityToUserData < ActiveRecord::Migration[7.0]
  def change
    add_column :user_data, :seniority, :tinyint, null: true
  end
end
