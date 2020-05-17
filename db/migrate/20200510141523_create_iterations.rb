class CreateIterations < ActiveRecord::Migration[6.0]
  def change
    create_table :iterations do |t|
      t.belongs_to :solution, foreign_key: true, null: false
      t.string :uuid, null: false

      t.integer :tests_status, null: false, default:0 
      t.integer :representation_status, null: false, default:0 
      t.integer :analysis_status, null: false, default: 0

      t.timestamps
    end
  end
end
