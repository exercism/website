class Submission::DiscussionPost::CreateFromRepresentation
  include Mandate

  initialize_with :submission, :submission_representation, :exercise_representation

  def call
    Submission::DiscussionPost.create!(
      submission: submission,
      source: submission_representation,
      content_markdown: exercise_representation.feedback_markdown,
      user: exercise_representation.feedback_author
    )
  end
end
