class AddChatGPTUsage < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    # TODO: I'd rather this was in user::data but that's not merged yet
    add_column :users, :usages, :json, null: true
  end
end
