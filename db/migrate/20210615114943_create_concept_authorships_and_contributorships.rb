class CreateConceptAuthorshipsAndContributorships < ActiveRecord::Migration[6.1]
  def change
    create_table :concept_authorships do |t|
      t.belongs_to :track_concept, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps

      t.index %i[track_concept_id user_id], unique: true
    end

    create_table :concept_contributorships do |t|
      t.belongs_to :track_concept, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps

      t.index %i[track_concept_id user_id], unique: true
    end
  end
end
