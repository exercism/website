class AddIndexToHandle < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :handle, unique: true
  end
end
