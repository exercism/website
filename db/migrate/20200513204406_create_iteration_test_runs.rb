class CreateIterationTestRuns < ActiveRecord::Migration[6.0]
  def change
    create_table :iteration_test_runs do |t|
      t.belongs_to :iteration, foreign_key: true, null: false

      t.string :status, null: false
      t.text :message, null: true
      t.json :tests, null: true

      t.integer :ops_status, limit: 2, null: false
      t.text :ops_message

      t.json :raw_results, null: false

      t.timestamps
    end
  end
end
