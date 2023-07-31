class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :uuid, null: false, index: {unique: true}

      t.belongs_to :track, optional: true, foreign_key: true

      t.string :section, null: false
      t.string :slug, null: false, index: true
      t.string :git_repo, null: false
      t.string :git_path, null: false

      t.string :title, null: false
      t.string :nav_title, null: true
      t.string :blurb, null: true

      t.timestamps
    end
  end
end
