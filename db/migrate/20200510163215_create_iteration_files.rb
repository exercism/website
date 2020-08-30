class CreateIterationFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :iteration_files do |t|
      t.belongs_to :iteration, foreign_key: true, null: false

      t.string :filename, null: false
      t.string :digest, null: false

      t.string :uri, null: false

      # The contents of this column needs moving to 
      # S3 as part of this migration.
      # t.binary :content, null: false

      t.timestamps
    end
  end
end
