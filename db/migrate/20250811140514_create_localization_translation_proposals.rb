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
      t.text :llm_feedback, null: true

      t.timestamps

      t.index :uuid, unique: true
    end

=begin

    Localization::Original.create!(
      key: "dashboard.welcome", 
      value: "Welcome back, %username%!", 
      context: "This string appears at the top of a user's dashboard, welcoming the back to the site."
    )
    en = Localization::Translation.create!(locale: "en", key: "dashboard.welcome", value: "Welcome back, %username%!")
    hu = Localization::Translation.create!(locale: "hu", key: "dashboard.welcome", value: "Üdv újra, %username%!")

    Localization::TranslationProposal.create!(
      translation: hu,
      value: "Üdv újra, %username%!",
      proposer: User.first,
      modified_from_llm: true
    )

    hu.update(status: :proposed)

=end
  end
end
