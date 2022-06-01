class SerializeMentorDiscussionForMentor
  include Mandate

  def initialize(discussion, relationship: nil)
    @discussion = discussion
    @relationship = relationship ||
                    Mentor::StudentRelationship.where(mentor:, student:).first
  end

  def call
    SerializeMentorDiscussion.(
      discussion,
      !!relationship&.favorited?,
      discussion.finished_for_mentor?,
      discussion.posts.where(seen_by_mentor: false).exists?,
      {
        self: Exercism::Routes.mentoring_discussion_url(discussion),
        posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion),
        finish: Exercism::Routes.finish_api_mentoring_discussion_url(discussion),
        mark_as_nothing_to_do: Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_url(discussion)
      }
    )
  end

  private
  attr_reader :discussion, :relationship

  delegate :mentor, :student, to: :discussion
end
