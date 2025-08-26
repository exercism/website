class CreateLocalizationOriginals < ActiveRecord::Migration[7.1]
  def change
    create_table :localization_originals do |t|
      t.string :uuid, null: false
      t.string :type, null: false

      t.string :about_type, null: true
      t.bigint :about_id, null: true

      t.string :key, null: false
      t.text :value, null: false
      t.text :usage_details, null: true
      t.timestamps

      t.index :uuid, unique: true
      t.index :key, unique: true
      t.index :type
      t.index [:type, :about_type, :about_id]
    end
  end
end
