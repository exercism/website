class Exercise::Representation < ApplicationRecord
  enum action: { pending: 0, approve: 1, disapprove: 2 }
  has_markdown_field :feedback

  belongs_to :exercise
  belongs_to :source_iteration, class_name: "Iteration"
  belongs_to :feedback_author, optional: true, class_name: "User"
  belongs_to :feedback_editor, optional: true, class_name: "User"

  has_many :iteration_representations, class_name: "Iteration::Representation",
                                       foreign_key: :ast_digest,
                                       primary_key: :ast_digest,
                                       inverse_of: :exercise_representations

  scope :order_by_frequency, lambda {
    left_joins(:iteration_representations).
      order("iteration_representations_count DESC").
      group("iteration_representations.ast_digest").
      select("exercise_representations.*, COUNT(iteration_representations.id) as iteration_representations_count")
  }

  def num_times_used
    iteration_representations.count
  end

  def has_feedback?
    feedback_markdown.present? && feedback_author_id.present?
  end
end
