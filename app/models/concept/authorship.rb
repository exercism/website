class Concept::Authorship < ApplicationRecord
  belongs_to :concept,
    inverse_of: :authorships,
    foreign_key: :track_concept_id # TODO: Remove at ETL

  belongs_to :author,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :authorships
end
