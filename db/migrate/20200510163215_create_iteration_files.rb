class CreateIterationFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :iteration_files do |t|
      t.belongs_to :iteration, foreign_key: true, null: false

      t.string :filename, null: false
      t.binary :contents, null: false
      t.text :digest, null: false

      t.timestamps
    end
  end
end
