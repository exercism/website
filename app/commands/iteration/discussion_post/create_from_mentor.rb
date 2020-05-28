class Iteration::DiscussionPost::CreateFromMentor
  include Mandate

  initialize_with :iteration, :discussion, :content_markdown

  def call
    Iteration::DiscussionPost.create!(
      iteration: iteration,
      source: discussion,
      content_markdown: content_markdown,
      user: discussion.mentor
    )
  end
end

