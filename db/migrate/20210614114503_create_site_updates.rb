class CreateSiteUpdates < ActiveRecord::Migration[7.0]
  def change
    create_table :site_updates do |t|
      t.string :type, null: false
      t.string :uniqueness_key, null: false
      t.text :params, null: false
      t.integer :version, null: false
      t.text :rendering_data_cache, null: false
      t.belongs_to :track, optional: true, foreign_key: true
      t.belongs_to :exercise, optional: true, foreign_key: true

      t.belongs_to :author, optional: true, foreign_key: { to_table: :users }
      t.belongs_to :pull_request, optional: true, foreign_key: { to_table: "github_pull_requests" }
      t.datetime :published_at, null: false

      t.string :title, null: true
      t.text :description, null: true

      t.timestamps
    end
  end
end
