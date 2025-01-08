class AddBootcampRolesToUserData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_data, :bootcamp_attendee, :boolean, null: false, default: false
    add_column :user_data, :bootcamp_mentor, :boolean, null: false, default: false
  end
end
