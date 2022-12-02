class User::TrackMentorship < ApplicationRecord
  belongs_to :user
  belongs_to :track

  scope :supermentor, -> { where('num_finished_discussions >= ?', Mentor::Supermentor::MIN_FINISHED_MENTORING_SESSIONS) }
end
