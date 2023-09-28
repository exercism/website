class Mentor::Discussion::ProcessFinished
  include Mandate

  initialize_with :discussion

  def call
    update_mentor_stats!
    award_student_trophies!
    award_reputation!
    log_metric!
  end

  private
  def update_mentor_stats! = Mentor::UpdateStats.defer(mentor, track)
  def award_student_trophies! = AwardTrophyJob.perform_later(student, track, :mentored)

  def award_reputation!
    return if rating == :problematic

    User::ReputationToken::Create.defer(
      mentor,
      :mentored,
      discussion:
    )
  end

  def log_metric!
    Metric::Queue.(:finish_mentoring, discussion.finished_at, discussion:, track:, user: student)
  end

  delegate :track, :student, :mentor, :rating, to: :discussion
end
