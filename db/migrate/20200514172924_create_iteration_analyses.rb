class CreateIterationAnalyses < ActiveRecord::Migration[6.0]
  def change
    create_table :iteration_analyses do |t|
      t.belongs_to :iteration, foreign_key: true, null: false
      
      t.string :status, null: false
      t.json :comments_data, null: true

      t.json :raw_analysis, null: true

      t.integer :ops_status, limit: 2, null: false
      t.text :ops_message

      t.timestamps
    end
  end
end
