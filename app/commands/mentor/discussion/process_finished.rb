class Mentor::Discussion::ProcessFinished
  include Mandate

  initialize_with :discussion, :rating

  def call
    award_reputation!
    award_badges!
    award_trophies!
    update_roles!
    log_metric!
  end

  private
  def award_reputation!
    return unless rating.nil? || rating >= 3

    User::ReputationToken::Create.defer(
      mentor,
      :mentored,
      discussion:
    )
  end

  def award_badges!
    AwardBadgeJob.perform_later(mentor, :mentor)
  end

  def award_trophies!
    AwardTrophyJob.perform_later(student, track, :mentored)
  end

  def update_roles!
    User::UpdateMentorRoles.defer(mentor)
  end

  def log_metric!
    Metric::Queue.(:finish_mentoring, discussion.finished_at, discussion:, track:, user: student)
  end

  delegate :track, :student, :mentor, to: :discussion
end
