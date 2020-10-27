class CreateIterations < ActiveRecord::Migration[6.1]
  def change
    create_table :iterations do |t|
      t.belongs_to :solution, foreign_key: true, null: false
      t.belongs_to :submission, foreign_key: true, null: false, index: {unique: true}
      
      t.integer :idx, null: false, limit: 1

      t.timestamps
    end
  end
end
