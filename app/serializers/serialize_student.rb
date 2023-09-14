class SerializeStudent
  include Mandate

  initialize_with :student, :mentor, user_track: Mandate::NO_DEFAULT, relationship: Mandate::NO_DEFAULT,
    anonymous_mode: Mandate::NO_DEFAULT, discussion: nil

  def call
    return anonymous_details if anonymous_mode

    {
      handle: student.handle,
      flair: student.flair,
      name: student.name.presence, # TODO: We need a flag to protect this maybe?
      bio: student.bio.presence,
      location: student.location.presence,
      languages_spoken: student.languages_spoken,
      avatar_url: student.avatar_url,
      reputation: student.formatted_reputation,
      pronouns:,
      is_favorited: !!relationship&.favorited?,
      is_blocked: !!relationship&.blocked_by_mentor?,
      track_objectives: user_track&.objectives.to_s,
      num_total_discussions:,
      num_discussions_with_mentor: relationship&.num_discussions.to_i,
      links:
    }
  end

  private
  def anonymous_details
    {
      name: "User in Anonymous mode",
      handle: "anonymous",
      reputation: 0,
      num_discussions_with_mentor: 0
    }
  end

  def pronouns
    student.pronouns.present? ? student.pronoun_parts : nil
  end

  def num_total_discussions
    Mentor::Discussion.joins(:solution).where('solutions.user_id': student.id).count
  end

  def links
    {
      block: Exercism::Routes.block_api_mentoring_student_path(student.handle),
      favorite: if Mentor::StudentRelationship::ToggleFavorited.new(mentor, student, false).allowed?
                  Exercism::Routes.favorite_api_mentoring_student_path(student.handle)
                end,
      previous_sessions: Exercism::Routes.api_mentoring_discussions_path(student: student.handle, status: :all,
        exclude_uuid: discussion.try(:uuid))
    }.compact
  end
end
