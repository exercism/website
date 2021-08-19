class AddTokenToCommunicationPreferences < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:user_communication_preferences, :token)
      add_column :user_communication_preferences, :token, :string
      User::CommunicationPreferences.update_all('token = UUID()')
      change_column_null :user_communication_preferences, :token, false
      add_index :user_communication_preferences, :token, unique: true
    end
  end
end
