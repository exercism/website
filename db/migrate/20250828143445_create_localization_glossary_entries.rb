class CreateLocalizationGlossaryEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :localization_glossary_entries do |t|
      t.string :locale, null: false
      t.string :term, null: false
      t.string :translation, null: false
      t.text :llm_instructions, null: false

      t.timestamps
      
      t.index [:locale, :term], unique: true
    end
  end
end
