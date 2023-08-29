class AddVersionToUsers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :users, :version, :smallint, null: false, default: 0
  end
end
