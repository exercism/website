class CreateLocalizationGlossaryEntryProposals < ActiveRecord::Migration[7.1]
  def change
    create_table :localization_glossary_entry_proposals do |t|
      t.integer :type, null: false
      t.integer :status, null: false, default: 0
      t.string :uuid, null: false

      t.belongs_to :glossary_entry, foreign_key: { to_table: "localization_glossary_entries" }, null: true

      t.belongs_to :proposer, null: false, foreign_key: { to_table: :users }
      t.belongs_to :reviewer, null: true, foreign_key: { to_table: :users }

      # Different ones of these are required for different types
      t.string :term, null: true
      t.string :locale, null: true
      t.string :translation, null: true
      t.text :llm_instructions, null: true

      t.timestamps
    end
  end
end
