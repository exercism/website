class User::TrackMentorship < ApplicationRecord
  belongs_to :user
  belongs_to :track

  scope :automator, -> { where(automator: true) }
end
