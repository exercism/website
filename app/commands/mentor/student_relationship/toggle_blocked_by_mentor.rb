class Mentor::StudentRelationship::ToggleBlockedByMentor
  include Mandate

  initialize_with :mentor, :student, :blocked

  def call
    return unless Mentor::Discussion.between(mentor:, student:).exists?

    relationship = Mentor::StudentRelationship.create_or_find_by!(
      mentor:,
      student:
    )

    if blocked
      relationship.update_columns(blocked_by_mentor: true, favorited: false)
    else
      relationship.update_columns(blocked_by_mentor: false)
    end
  end
end
