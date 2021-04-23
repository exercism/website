class SerializeMentorStudentRelationship
  include Mandate

  initialize_with :relationship

  def call
    return if relationship.blank?

    {
      is_favorited: relationship.favorited?,
      is_blocked_by_mentor: relationship.blocked_by_mentor?,
      links: {
        block: Exercism::Routes.block_api_mentoring_student_path(relationship.student.handle),
        favorite: Exercism::Routes.favorite_api_mentoring_student_path(relationship.student.handle)
      }
    }
  end
end
