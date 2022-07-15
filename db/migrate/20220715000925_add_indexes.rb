class AddIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :solutions, [:exercise_id, :published_at]
  end
end
