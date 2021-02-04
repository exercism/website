class SerializeMentorStudentRelationship
  include Mandate

  initialize_with :relationship

  def call
    {
      isFavorited: relationship.favorite,
      links: {
        mentor_again: Exercism::Routes.mark_as_mentor_again_api_mentor_student_relationship_path(relationship),
        dont_mentor_again: Exercism::Routes.mark_as_dont_mentor_again_api_mentor_student_relationship_path(relationship),
        favorite: Exercism::Routes.api_mentor_favorite_student_path(student_handle: relationship.student.handle)
      }
    }
  end
end
