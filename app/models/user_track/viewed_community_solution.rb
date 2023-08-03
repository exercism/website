class UserTrack::ViewedCommunitySolution < ApplicationRecord
  belongs_to :user
  belongs_to :track
  belongs_to :solution
end
