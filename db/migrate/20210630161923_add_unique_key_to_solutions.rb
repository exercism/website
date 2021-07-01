class AddUniqueKeyToSolutions < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :unique_key, :string, null: true

    Solution.update_all('unique_key = CONCAT(user_id, ":", exercise_id)')

    change_column_null :solutions, :unique_key, false

    add_index :solutions, :unique_key, unique: true
    remove_index :solutions, [:user_id, :exercise_id] # index_solutions_on_exercise_id_and_user_id
  end
end
