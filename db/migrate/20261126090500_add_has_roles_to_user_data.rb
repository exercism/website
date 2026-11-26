# The admin Roles page lists every user with a role. Without an index it had to
# read every row of user_data, so this adds a generated column it can index.
#
# Production already has the column and index: they were added by hand on
# 2026-11-26 while the page was timing out.
class AddHasRolesToUserData < ActiveRecord::Migration[7.1]
  def up
    return if Rails.env.production?

    unless column_exists?(:user_data, :has_roles)
      add_column :user_data, :has_roles, :virtual, type: :boolean,
        as: "(coalesce(json_length(`roles`),0) > 0)", stored: false
    end

    add_index :user_data, :has_roles unless index_exists?(:user_data, :has_roles)
  end

  def down
    return if Rails.env.production?

    remove_index :user_data, :has_roles if index_exists?(:user_data, :has_roles)
    remove_column :user_data, :has_roles if column_exists?(:user_data, :has_roles)
  end
end
