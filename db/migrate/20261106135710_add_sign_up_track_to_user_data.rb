class AddSignUpTrackToUserData < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    # The language someone picked in the sign-up code check.
    add_reference :user_data, :sign_up_track, null: true, foreign_key: { to_table: :tracks }
  end
end
