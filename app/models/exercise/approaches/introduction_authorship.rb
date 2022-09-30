class Exercise::Approaches::IntroductionAuthorship < ApplicationRecord
  # TODO: figure out how to remove this
  self.table_name = "exercise_approach_introduction_authorships"

  belongs_to :exercise
  belongs_to :author,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :approach_introduction_authorships
end
