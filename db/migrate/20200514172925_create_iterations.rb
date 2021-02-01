class CreateIterations < ActiveRecord::Migration[6.1]
  def change
    create_table :iterations do |t|
      t.belongs_to :solution, foreign_key: true, null: false
      t.belongs_to :submission, foreign_key: true, null: false, index: {unique: true}
      
      t.string :uuid, null: false
      t.integer :idx, null: false, limit: 1

      t.boolean :published, null: false, default: false

      t.timestamps
    end
  end
end
