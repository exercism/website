class CreateGenericExercises < ActiveRecord::Migration[7.0]
  def change
    create_table :generic_exercises do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :blurb, null: false
      t.string :source, null: true
      t.string :source_url, null: true
      t.string :deep_dive_youtube_id, null: true

      t.timestamps
    end
  end
end
