class CreateLocalizationTranslationProposals < ActiveRecord::Migration[7.1]
  def change
    create_table :localization_translation_proposals, if_not_exists: true do |t|
      t.string :uuid, null: false

      t.belongs_to :translation, null: false, foreign_key: { to_table: :localization_translations }
      t.belongs_to :proposer, null: false, foreign_key: { to_table: :users }
      t.belongs_to :reviewer, null: true, foreign_key: { to_table: :users }

      t.integer :status, null: false, default: 0
      t.boolean :modified_from_llm, null: false
      t.text :value, null: false

      t.timestamps

      t.index :uuid, unique: true
    end

    # translation = Localization::Translation.second
    # Localization::TranslationProposal.create!(
    #   translation: translation,
    #   value: "Reading Better HU",
    #   proposer: User.first,
    #   modified_from_llm: true
    # )
    # Localization::TranslationProposal.create!(
    #   translation: translation,
    #   value: "Reading A different Better HU",
    #   proposer: User.first,
    #   modified_from_llm: true
    # )
    # translation.update(status: :proposed)
  end
end
