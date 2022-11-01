class Exercise::Approach::Authorship < ApplicationRecord
  belongs_to :approach,
    class_name: "Exercise::Approach",
    foreign_key: :exercise_approach_id,
    inverse_of: :authorships

  belongs_to :author,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :approach_authorships
end
