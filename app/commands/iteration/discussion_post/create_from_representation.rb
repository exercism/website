class Iteration::DiscussionPost::CreateFromRepresentation
  include Mandate

  initialize_with :iteration, :iteration_representation, :exercise_representation

  def call
    Iteration::DiscussionPost.create!(
      iteration: iteration,
      source: iteration_representation,
      content_markdown: exercise_representation.feedback_markdown,
      user: exercise_representation.feedback_author
    )
  end
end
