class CreateTrackTags < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :track_tags do |t|
      t.bigint :track_id, null: false
      t.string :tag, null: false
      t.boolean :enabled, default: true, null: false
      t.boolean :filterable, default: true, null: false

      t.timestamps
    end
  end
end
