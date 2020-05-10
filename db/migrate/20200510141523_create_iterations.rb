class CreateIterations < ActiveRecord::Migration[6.0]
  def change
    create_table :iterations do |t|
      t.belongs_to :solution, null: false

      t.timestamps
    end
  end
end
