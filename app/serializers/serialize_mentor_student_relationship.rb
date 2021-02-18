class SerializeMentorStudentRelationship
  include Mandate

  initialize_with :relationship

  def call
    return if relationship.blank?

    {
      isFavorited: relationship.favorited?,
      isBlocked: relationship.blocked?,
      links: {
        block: Exercism::Routes.block_api_mentoring_student_path(relationship.student.handle),
        favorite: Exercism::Routes.favorite_api_mentoring_student_path(relationship.student.handle)
      }
    }
  end
end
