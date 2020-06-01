class Exercise::Representation < ApplicationRecord
  enum action: [:pending, :approve, :disapprove]
  has_markdown_field :feedback

  belongs_to :exercise
  belongs_to :feedback_author, optional: true, class_name: "User"
  belongs_to :feedback_editor, optional: true, class_name: "User"

  has_many :iteration_representations, class_name: "Iteration::Representation", foreign_key: :ast_digest, primary_key: :ast_digest

  scope :order_by_frequency, -> { 
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
