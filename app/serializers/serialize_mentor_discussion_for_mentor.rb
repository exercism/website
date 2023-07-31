class SerializeMentorDiscussionForMentor
  include Mandate

  # We pass relationship: false if there's not one.
  # and the same for has_unseen_post.
  # In both cases, nil signifies missing data, not negative data
  def initialize(discussion, relationship: nil, has_unseen_post: nil)
    @discussion = discussion

    @relationship = relationship.nil? ?
      Mentor::StudentRelationship.where(mentor:, student:).first :
      relationship.presence # We need to mutate this to be nil not false

    @has_unseen_post = has_unseen_post.nil? ?
      discussion.posts.where(seen_by_mentor: false).exists? :
      has_unseen_post
  end

  def call
    SerializeMentorDiscussion.(
      discussion,
      !!relationship&.favorited?,
      discussion.finished_for_mentor?,
      has_unseen_post,
      {
        self: Exercism::Routes.mentoring_discussion_url(discussion),
        posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion),
        finish: Exercism::Routes.finish_api_mentoring_discussion_url(discussion),
        mark_as_nothing_to_do: Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_url(discussion),
        tooltip_url: Exercism::Routes.api_mentoring_student_path(discussion.student, track_slug: discussion.track.slug)
      }
    )
  end

  private
  attr_reader :discussion, :relationship, :has_unseen_post

  delegate :mentor, :student, to: :discussion
end
