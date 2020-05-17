class CreateIterationRepresentations < ActiveRecord::Migration[6.0]
  def change
    create_table :iteration_representations do |t|
      t.belongs_to :iteration, foreign_key: true, null: false

      t.integer :ops_status, limit: 2, null: false
      t.text :ops_message

      t.text :ast, null: true
      t.string :ast_digest, null: false

      t.timestamps
    end
  end
end
