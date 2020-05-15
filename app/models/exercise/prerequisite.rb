class Exercise::Prerequisite < ApplicationRecord
  belongs_to :exercise
  belongs_to :track_concept, class_name: "Track::Concept"
end
