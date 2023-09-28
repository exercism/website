class UpdateAutomatorRolesJob < ApplicationJob
  queue_as :dribble

  def perform
    User::TrackMentorship.includes(:user, :track).automator.find_each do |mentorship|
      User::UpdateAutomatorRole.(mentorship.user, mentorship.track)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end
end
