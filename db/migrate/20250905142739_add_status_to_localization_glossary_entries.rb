class AddStatusToLocalizationGlossaryEntries < ActiveRecord::Migration[7.1]
  def change
    add_column :localization_glossary_entries, :status, :integer, default: 1, null: false
    add_column :localization_glossary_entries, :uuid, :string, null: false
    add_index :localization_glossary_entries, :uuid, unique: true
  end
end
