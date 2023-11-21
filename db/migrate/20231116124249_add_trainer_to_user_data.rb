class AddTrainerToUserData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_data, :trainer, :boolean, null: false, default: false
  end
end
