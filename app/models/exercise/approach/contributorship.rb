class Exercise::Approach::Contributorship < ApplicationRecord
  belongs_to :approach,
    class_name: "Exercise::Approach",
    foreign_key: :exercise_approach_id,
    inverse_of: :contributorships

  belongs_to :contributor,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :approach_contributorships
end
