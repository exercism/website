class CreateLocalizationOriginals < ActiveRecord::Migration[7.1]
  def change
    create_table :localization_originals, if_not_exists: true do |t|
      t.string :uuid, null: false
      t.string :type, null: false

      t.string :key, null: false
      t.text :value, null: false
      t.text :data, null: false
      t.timestamps

      t.index :uuid, unique: true
      t.index :key, unique: true
    end
  end
end
