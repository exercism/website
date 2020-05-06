class UserTrack < ApplicationRecord
  belongs_to :user
  belongs_to :track
end
