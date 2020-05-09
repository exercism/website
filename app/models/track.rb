class Track < ApplicationRecord
  has_many :concepts, class_name: "TrackConcept"
  has_many :exercises
  #has_many :concept_exercises
  #has_many :practice_exercises

  def self.for!(param)
    return param if param.is_a?(Track)
    return find_by_id!(param) if param.is_a?(Numeric)
    find_by_slug!(param)
  end
end
