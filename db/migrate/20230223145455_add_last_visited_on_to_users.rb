class AddLastVisitedOnToUsers < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :users, :last_visited_on, :date, null: true
      add_index :users, :last_visited_on, unique: false, if_not_exists: true
    end
  end
end
