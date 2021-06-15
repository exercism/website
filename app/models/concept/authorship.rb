class Concept::Authorship < ApplicationRecord
  belongs_to :concept,
    class_name: "Track::Concept" # TODO: remove after PR is merged
  belongs_to :author,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :authorships
end
