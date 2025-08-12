class CreateLocalizationOriginals < ActiveRecord::Migration[7.1]
  def change
    create_table :localization_originals, if_not_exists: true do |t|
      t.string :uuid, null: false
      t.string :key, null: false
      t.text :value, null: false
      t.text :sample_interpolations, null: false
      t.timestamps

      t.index :key, unique: true
    end

    # Localization::Original.create!(key: "hello.world", value: "Reading EN")
  end
end
