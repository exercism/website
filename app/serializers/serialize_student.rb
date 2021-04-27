class SerializeStudent
  include Mandate

  initialize_with :student, :mentor_relationship, :anonymous

  def call
    return anonymous_details if anonymous

    {
      id: student.id,
      name: student.name,
      handle: student.handle,
      bio: student.bio,
      languages_spoken: student.languages_spoken,
      avatar_url: student.avatar_url,
      reputation: student.formatted_reputation,
      is_favorited: !!mentor_relationship&.favorited?,
      is_blocked: !!mentor_relationship&.blocked_by_mentor?,
      num_previous_sessions: num_previous_sessions,
      links: {
        block: Exercism::Routes.block_api_mentoring_student_path(student.handle),
        favorite: Exercism::Routes.favorite_api_mentoring_student_path(student.handle),
        previous_sessions: Exercism::Routes.api_mentoring_discussions_path(student: student.handle, status: :all)
      }
    }
  end

  def anonymous_details
    {
      id: "anon-#{SecureRandom.uuid}",
      name: "User in Anonymous mode",
      handle: "anonymous",
      reputation: 0,
      num_previous_sessions: 0
    }
  end

  # TODO: I'm not happy with this here. I think the -1 should be done
  # in the JS and this should return num_discussions
  def num_previous_sessions
    num = mentor_relationship&.num_discussions.to_i
    num.positive? ? num - 1 : 0 # Previous does not include this
  end
end
