class CreateIterationFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :iteration_files do |t|
      t.belongs_to :iteration, foreign_key: true, null: false

      t.string :uuid, null: false
      t.string :filename, null: false
      t.string :digest, null: false

      # We're going to save content for now
      # to make local development easier and 
      # to keep old content inline for now.
      # Once we're happy everything is in S3, 
      # we can delete this column
      t.binary :content, null: false

      t.timestamps
    end
  end
end
