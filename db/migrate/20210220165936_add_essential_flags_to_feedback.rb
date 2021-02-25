class AddEssentialFlagsToFeedback < ActiveRecord::Migration[6.1]
  def change
    add_column :exercise_representations, :feedback_type, :tinyint, null: true
  end
end
