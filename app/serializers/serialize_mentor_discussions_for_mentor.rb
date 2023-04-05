class SerializeMentorDiscussionsForMentor
  include Mandate

  initialize_with :discussions, :mentor

  def call
    discussions.includes(:solution, :exercise, :track, :student, :mentor).map { |d| serialize_discussion(d) }
  end

  private
  def serialize_discussion(discussion)
    relationship = relationships[discussion.student.id]
    tooltip_url = Exercism::Routes.api_mentoring_student_path(discussion.student, track_slug: discussion.track.slug)

    SerializeMentorDiscussionForMentor.(discussion, relationship:).tap do |hash|
      hash.merge!(
        tooltip_url:
      )
    end
  end

  memoize
  def relationships
    student_ids = discussions.map { |d| d.student.id }
    Mentor::StudentRelationship.where(mentor:, student_id: student_ids).index_by(&:student_id)
  end
end
