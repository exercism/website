class User::TrackMentorship < ApplicationRecord
  belongs_to :user
  belongs_to :track
end
