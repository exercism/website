class CreateConceptAuthorshipsAndContributorships < ActiveRecord::Migration[7.0]
  def change
    create_table :track_concept_authorships do |t|
      t.belongs_to :track_concept, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps

      t.index %i[track_concept_id user_id], unique: true, name: "index_concept_authorships_concept_id_user_id"
    end

    create_table :track_concept_contributorships do |t|
      t.belongs_to :track_concept, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps

      t.index %i[track_concept_id user_id], unique: true, name: "index_concept_contributorships_concept_id_user_id"
    end
  end
end
