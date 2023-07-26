class Mentor::StudentRelationship::ToggleFavorited
  include Mandate

  initialize_with :mentor, :student, :favorited

  def call
    return unless allowed?

    relationship = Mentor::StudentRelationship.create_or_find_by!(
      mentor:,
      student:
    )
    relationship.update_column(:favorited, favorited)
  end

  def allowed?
    Mentor::Discussion.between(mentor:, student:).exists?
  end
end
