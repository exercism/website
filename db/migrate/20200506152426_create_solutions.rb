class CreateSolutions < ActiveRecord::Migration[7.0]
  def change
    create_table :solutions do |t|
      t.string :type, null: false
      t.string :unique_key, null: false, index: {unique: true}

      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :exercise, foreign_key: true, null: false
      t.belongs_to :published_iteration, null: true

      t.string :uuid, null: false, index: {unique: true}
      t.string :public_uuid, null: false, index: {unique: true}

      t.string :git_slug, null: false
      t.string :git_sha, null: false
      t.string :git_important_files_hash, null: false

      t.column :status, :tinyint, default: 0, null: false
      t.string :iteration_status, null: true

      t.boolean :allow_comments, default: true, null: false

      t.datetime :last_iterated_at, null: true
      t.column :num_iterations, :tinyint, default: 0, null: false

      t.string :snippet, null: true, limit: 1500

      t.datetime :downloaded_at, null: true
      t.datetime :completed_at, null: true
      t.datetime :published_at, null: true

      t.column :mentoring_status, :tinyint, null: false, default: 0

      t.integer :num_views, limit: 3, null: false, default: 0
      t.integer :num_stars, limit: 3, null: false, default: 0
      t.integer :num_comments, limit: 3, null: false, default: 0
      t.integer :num_loc, limit: 3, null: false, default: 0

      t.timestamps
    end
  end
end
