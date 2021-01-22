class Exercise::Representation < ApplicationRecord
  has_markdown_field :feedback

  belongs_to :exercise
  belongs_to :source_submission, class_name: "Submission"
  belongs_to :feedback_author, optional: true, class_name: "User"
  belongs_to :feedback_editor, optional: true, class_name: "User"

  # TOOD: We're going to need some indexes here!
  has_many :submission_representations,
    ->(er) { joins(:solution).where("solutions.exercise_id": er.exercise_id) },
    class_name: "Submission::Representation",
    foreign_key: :ast_digest,
    primary_key: :ast_digest,
    inverse_of: :exercise_representation

  # TOOD: We're going to need some indexes here!
  scope :order_by_frequency, lambda {
    joins("
      LEFT JOIN submission_representations
      ON submission_representations.ast_digest = exercise_representations.ast_digest
      JOIN submissions ON submission_representations.submission_id = submissions.id
      JOIN solutions ON submissions.solution_id = solutions.id
    ").
      where("solutions.exercise_id = exercise_representations.exercise_id").
      order("submission_representations_count DESC").
      group("submission_representations.ast_digest").
      select("exercise_representations.*, COUNT(submission_representations.id) as submission_representations_count")
  }

  def num_times_used
    submission_representations.count
  end

  def has_feedback?
    [feedback_markdown, feedback_author_id].all?(&:present?)
  end
end
