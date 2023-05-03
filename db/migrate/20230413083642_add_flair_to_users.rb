class AddFlairToUsers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :users, :flair, :tinyint, null: true
  end
end
