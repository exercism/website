class CommunityVideo < ApplicationRecord
  enum status: { pending: 0, approved: 1, rejected: 2 }
  enum platform: { youtube: 1, vimeo: 2 }
  belongs_to :track, optional: true
  belongs_to :exercise, optional: true
  belongs_to :author, class_name: "User", optional: true

  belongs_to :submitted_by, class_name: "User"

  scope :for_exercise, ->(exercise) { where(exercise:) }

  def platform = super.to_sym

  after_save_commit do
    Exercise::UpdateHasApproaches.defer(exercise) if previous_changes.key?("status") && exercise.present?
  end
end
