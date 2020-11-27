class CreateTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :tracks do |t|
      t.string :slug, null: false, unique: true
      t.string :title, null: false
      t.string :blurb, null: false, limit: 400

      t.string :repo_url, null: false

      t.json :tags, null: true

      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
