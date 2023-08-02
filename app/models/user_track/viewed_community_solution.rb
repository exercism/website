class UserTrack::ViewedCommunitySolution < ApplicationRecord
  belongs_to :user_track
  belongs_to :solution
end
