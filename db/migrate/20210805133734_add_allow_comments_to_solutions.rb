class AddAllowCommentsToSolutions < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :allow_comments, :boolean, default: true, null: false
  end
end
