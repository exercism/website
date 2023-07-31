class CreateIterations < ActiveRecord::Migration[7.0]
  def change
    create_table :iterations do |t|
      t.belongs_to :solution, foreign_key: true, null: false
      t.belongs_to :submission, foreign_key: true, null: false, index: {unique: true}

      t.string :uuid, null: false
      t.integer :idx, null: false, limit: 1

      t.string :snippet, null: true, limit: 1500

      t.datetime :deleted_at, null: true

      t.timestamps
    end

    add_foreign_key :solutions, :iterations, column: :published_iteration_id
  end
end
