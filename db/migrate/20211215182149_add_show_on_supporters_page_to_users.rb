class AddShowOnSupportersPageToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :show_on_supporters_page, :boolean, default: true, null: false, if_not_exists: true

    add_index :users, [:total_donated_in_cents, :show_on_supporters_page], name: "users-supporters-page", if_not_exists: true
  end
end
