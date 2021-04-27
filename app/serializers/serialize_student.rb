class SerializeStudent
  include Mandate

  initialize_with :student, :mentor_relationship

  def call
    {
      id: student.id,
      name: student.name,
      handle: student.handle,
      bio: student.bio,
      languages_spoken: student.languages_spoken,
      avatar_url: student.avatar_url,
      reputation: student.formatted_reputation,
      is_favorite: !!mentor_relationship&.favorited?,
      num_previous_sessions: num_previous_sessions,
      links: {
        favorite: Exercism::Routes.favorite_api_mentoring_student_path(student.handle),
        previous_sessions: Exercism::Routes.api_mentoring_discussions_path(student: student.handle, status: :all)
      }
    }
  end

  # TODO: I'm not happy with this here. I think the -1 should be done
  # in the JS and this should return num_discussions
  def num_previous_sessions
    num = mentor_relationship&.num_discussions.to_i
    num.positive? ? num - 1 : 0 # Previous does not include this
  end
end
