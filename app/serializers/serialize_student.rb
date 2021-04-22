class SerializeStudent
  include Mandate

  initialize_with :student, :user

  def call
    {
      id: student.id,
      name: student.name,
      handle: student.handle,
      bio: student.bio,
      languages_spoken: student.languages_spoken,
      avatar_url: student.avatar_url,
      reputation: student.formatted_reputation,
      is_favorite: student.favorited_by?(user),
      num_previous_sessions: user.num_previous_mentor_sessions_with(student),
      links: {
        favorite: Exercism::Routes.favorite_api_mentoring_student_path(student.handle),
        previous_sessions: Exercism::Routes.api_mentoring_previous_discussions_path(handle: student.handle)
      }
    }
  end
end
