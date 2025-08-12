class CreateLocalizationTranslationProposals < ActiveRecord::Migration[7.1]
  def change
    create_table :localization_translation_proposals, if_not_exists: true do |t|
      t.belongs_to :translation, null: false, foreign_key: { to_table: :localization_translations }
      t.belongs_to :proposer, null: false, foreign_key: { to_table: :users }
      t.belongs_to :reviewer, null: false, foreign_key: { to_table: :users }

      t.integer :status, null: false, default: 0
      t.text :value, null: false

      t.timestamps
    end
  end
end
