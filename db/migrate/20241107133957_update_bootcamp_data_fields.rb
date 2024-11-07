class UpdateBootcampDataFields < ActiveRecord::Migration[7.0]
  def change
    change_column_null :user_bootcamp_data, :user_id, true
    add_column :user_bootcamp_data, :checkout_session_id, :string
  end
end
