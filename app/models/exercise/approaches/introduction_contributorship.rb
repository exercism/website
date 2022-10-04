class Exercise::Approaches::IntroductionContributorship < ApplicationRecord
  # TODO: figure out how to remove this
  self.table_name = "exercise_approach_introduction_contributorships"

  belongs_to :exercise
  belongs_to :contributor,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :approach_introduction_contributorships
end
