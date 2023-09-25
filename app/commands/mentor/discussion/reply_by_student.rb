class Mentor::Discussion::ReplyByStudent
  include Mandate

  initialize_with :discussion, :iteration, :content_markdown

  def call
    discussion_post = Mentor::DiscussionPost.create!(
      iteration:,
      discussion:,
      content_markdown:,
      author: iteration.solution.user,
      seen_by_student: true
    )

    Mentor::Discussion::AwaitingMentor.(discussion)

    User::Notification::Create.(
      discussion.mentor,
      :student_replied_to_discussion,
      discussion_post:
    )

    discussion_post
  end
end
