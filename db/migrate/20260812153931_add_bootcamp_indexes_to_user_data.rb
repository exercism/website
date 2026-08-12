class AddBootcampIndexesToUserData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :user_data, %i[bootcamp_attendee user_id], name: "index_user_data__bootcamp_attendees"
    add_index :user_data, %i[bootcamp_mentor user_id], name: "index_user_data__bootcamp_mentors"
  end
end
