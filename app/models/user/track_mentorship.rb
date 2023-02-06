class User::TrackMentorship < ApplicationRecord
  belongs_to :user
  belongs_to :track

  scope :supermentor_frequency, -> { where('num_finished_discussions >= ?', Mentor::Supermentor::MIN_FINISHED_MENTORING_SESSIONS) }
end
