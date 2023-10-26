class CreateTrainingTrackTagsTuples < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :training_track_tags_tuples do |t|
      t.belongs_to :track, null: false
      t.belongs_to :exercise, null: true
      t.belongs_to :solution, null: true
      t.integer :status, null: false, default: 0
      t.integer :dataset, null: false, default: 0
      t.text :code, null: false
      t.text :tags, null: true

      t.timestamps
    end
  end
end
