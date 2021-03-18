class CreateDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :documents do |t|
      t.string :uuid, null: false, index: {unique: true}

      t.belongs_to :track, optional: true, foreign_key: true

      t.string :slug, null: false, index: true
      t.string :git_repo, null: false
      t.string :git_path, null: false

      t.integer :type, null: true

      t.string :title, null: false
      t.string :blurb, null: true

      t.timestamps
    end
  end
end
