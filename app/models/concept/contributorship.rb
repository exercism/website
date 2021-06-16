class Concept::Contributorship < ApplicationRecord
  belongs_to :concept,
    inverse_of: :contributorships,
    foreign_key: :track_concept_id # TODO: Remove at ETL

  belongs_to :contributor,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :contributorships
end
