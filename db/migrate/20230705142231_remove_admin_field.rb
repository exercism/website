class RemoveAdminField < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    remove_column :users, :admin, if_exists: true
  end
end
