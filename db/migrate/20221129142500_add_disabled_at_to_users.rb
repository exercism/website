class AddDisabledAtToUsers < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :users, :disabled_at, :datetime, null: true, if_not_exists: true
    end
  end
end
