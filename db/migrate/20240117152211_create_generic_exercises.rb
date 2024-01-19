class CreateGenericExercises < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :generic_exercises do |t|
      t.string :slug, null: false, index: { unique: true }
      t.string :title, null: false, index: true
      t.string :blurb, null: false
      t.string :source, null: true
      t.string :source_url, null: true
      t.string :deep_dive_youtube_id, null: true
      t.integer :status, null: false, default: 0, size: 1

      t.timestamps
    end
  end
end
