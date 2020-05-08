# frozen_string_literal: true

class UserTrack < ApplicationRecord
  belongs_to :user
  belongs_to :track

  def self.for!(user_param, track_param)
    UserTrack.find_by!(
      user: User.for!(user_param),
      track: Track.for!(track_param)
    )
  end

  #def unlocked_concept_exercises
  #  track.concept_exercises.where(prerequisites: [])
  #end
end
