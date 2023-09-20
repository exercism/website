class Mentor::Discussion::ReplyByMentor
  include Mandate

  initialize_with :discussion, :iteration, :content_markdown

  def call
    discussion_post = Mentor::DiscussionPost.create!(
      iteration:,
      discussion:,
      content_markdown:,
      author: discussion.mentor,
      seen_by_mentor: true
    )

    Mentor::Discussion::AwaitingStudent.(discussion)

    Submission::Representation::UpdateMentor.defer(iteration.submission)

    User::Notification::Create.(
      iteration.solution.user,
      :mentor_replied_to_discussion,
      discussion_post:
    )

    discussion_post
  end
end
