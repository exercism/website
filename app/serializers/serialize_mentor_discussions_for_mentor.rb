class SerializeMentorDiscussionsForMentor
  include Mandate

  initialize_with :discussions, :mentor

  def call
    materialized_discussions.map { |d| serialize_discussion(d) }
  end

  private
  def serialize_discussion(discussion)
    SerializeMentorDiscussionForMentor.(
      discussion,
      # Explicitely pass false not nil as we check for false downstream
      relationship: relationships[discussion.student.id] || false,
      has_unseen_post: has_unseen_posts[discussion.id] || false
    )
  end

  memoize
  def relationships
    Mentor::StudentRelationship.where(
      mentor:, student_id: materialized_discussions.map { |d| d.student.id }
    ).index_by(&:student_id)
  end

  memoize
  def has_unseen_posts
    Mentor::DiscussionPost.where(
      discussion: materialized_discussions.map(&:id),
      seen_by_mentor: false
    ).index_by(&:discussion_id).
      transform_values { true } # Transform to be {$discussion_id: true}
  end

  memoize
  def materialized_discussions
    discussions.
      includes(
        :solution, :exercise, :track, :mentor, :student
      )
  end
end
