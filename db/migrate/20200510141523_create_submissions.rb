class CreateSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :submissions do |t|
      t.belongs_to :solution, foreign_key: true, null: false
      t.string :uuid, null: false, index: { unique: true }

      t.integer :tests_status, null: false, default: 0
      t.integer :representation_status, null: false, default: 0
      t.integer :analysis_status, null: false, default: 0

      t.string :submitted_via, null: false

      t.string :git_slug, null: false
      t.string :git_sha, null: false

      t.timestamps
    end
  end
end
