class CreateLocalizationTranslations < ActiveRecord::Migration[7.1]
  def change
    create_table :localization_translations, if_not_exists: true do |t|
      t.string :uuid, null: false
      t.string :locale, null: false
      t.string :key,    null: false
      t.text   :value,  null: false
      t.integer :status, null: false, default: 0

      t.timestamps

      t.foreign_key :localization_originals, column: :key, primary_key: :key
      t.index :uuid, unique: true
      t.index [:key, :locale], unique: true
      t.index :value, type: :fulltext

    end

    # Localization::Translation.create!(locale: "en", key: "hello.world", value: "Reading EN")
    # Localization::Translation.create!(locale: "hu", key: "hello.world", value: "Reading HU")
  end
end
