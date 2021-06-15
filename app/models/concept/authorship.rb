class Concept::Authorship < ApplicationRecord
  belongs_to :concept
  belongs_to :author,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :authorships
end
