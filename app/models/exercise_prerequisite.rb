class ExercisePrerequisite < ApplicationRecord
  belongs_to :exercise
  belongs_to :track_concept
end
