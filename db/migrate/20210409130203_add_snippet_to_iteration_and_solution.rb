class AddSnippetToIterationAndSolution < ActiveRecord::Migration[6.1]
  def change
    add_column :iterations, :snippet, :string, null: true, limit: 1500
    add_column :solutions, :snippet, :string, null: true, limit: 1500
  end
end
