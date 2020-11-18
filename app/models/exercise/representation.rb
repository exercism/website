class Exercise::Representation < ApplicationRecord
  enum action: { pending: 0, approve: 1, disapprove: 2 }
  has_markdown_field :feedback

  belongs_to :exercise
  belongs_to :source_submission, class_name: "Submission"
  belongs_to :feedback_author, optional: true, class_name: "User"
  belongs_to :feedback_editor, optional: true, class_name: "User"

  has_many :submission_representations, class_name: "Submission::Representation", # rubocop:disable Rails/InverseOf
                                        foreign_key: :ast_digest,
                                        primary_key: :ast_digest

  scope :order_by_frequency, lambda {
    left_joins(:submission_representations).
      order("submission_representations_count DESC").
      group("submission_representations.ast_digest").
      select("exercise_representations.*, COUNT(submission_representations.id) as submission_representations_count")
  }

  def num_times_used
    submission_representations.count
  end

  def has_feedback?
    feedback_markdown.present? && feedback_author_id.present?
  end
end
