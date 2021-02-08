class SerializeMentorStudentRelationship
  include Mandate

  initialize_with :relationship

  def call
    return if relationship.blank?

    {
      isFavorited: relationship.favorited?,
      isBlocked: relationship.blocked?,
      links: {
        block: Exercism::Routes.api_mentor_block_student_path(student_handle: relationship.student.handle),
        favorite: Exercism::Routes.api_mentor_favorite_student_path(student_handle: relationship.student.handle)
      }
    }
  end
end
