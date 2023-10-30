class Exercise::Representation::Recache
  include Mandate

  queue_as :solution_processing

  initialize_with :representation, last_submitted_at: nil, force: false

  def call
    update_model!

    return unless representation_changed? || force

    Exercise::Representation::UpdateNumSubmissions.defer(representation)
    Exercise::Representation::SyncToSearchIndex.defer(representation)
  end

  private
  delegate :exercise, to: :representation

  def update_model!
    attrs = {
      oldest_solution:,
      prestigious_solution:,
      num_published_solutions: representation.published_solutions.count
    }

    attrs[:last_submitted_at] = last_submitted_at if last_submitted_at
    representation.update!(attrs)
  end

  def oldest_solution
    representation.published_solutions.
      where.not(user_id: User::GHOST_USER_ID).
      first
  end

  def prestigious_solution
    user_id = User::ReputationToken.where(
      track_id: exercise.track_id,
      user_id: representation.published_solutions.select(:user_id)
    ).
      group(:user_id).
      select("user_id, SUM(value) as total").
      order('total DESC').
      first&.user_id

    return oldest_solution unless user_id

    representation.published_solutions.find_by!(user_id:)
  end

  memoize
  def representation_changed?
    representation.previous_changes.present?
  end
end
