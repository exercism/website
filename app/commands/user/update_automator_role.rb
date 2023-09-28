class User::UpdateAutomatorRole
  include Mandate

  initialize_with :user, :track

  def call = mentorship.update!(automator: eligible?)

  private
  def eligible?
    return true if explicit?
    return false unless user.mentor?
    return false unless mentorship
    return false if user.mentor_satisfaction_percentage.to_i < MIN_SATISFACTION_PERCENTAGE
    return false if mentorship.num_finished_discussions < MIN_FINISHED_MENTORING_SESSIONS

    true
  end

  def mentorship = user.track_mentorships.find_by(track:)
  def explicit? = automators.fetch(user.handle, []).include?(track.slug)

  memoize
  def automators
    Git::WebsiteCopy.new.automators.map { |automator| [automator[:username], automator[:tracks]] }.to_h
  end

  MIN_SATISFACTION_PERCENTAGE = 95
  MIN_FINISHED_MENTORING_SESSIONS = 100
end
