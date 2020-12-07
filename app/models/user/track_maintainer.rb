class User::TrackMaintainer < ApplicationRecord
  belongs_to :user
  belongs_to :track
end
