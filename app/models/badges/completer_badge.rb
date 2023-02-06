module Badges
  class CompleterBadge < Badge
    seed "Completer",
      :ultimate,
      :completer,
      "Completed all exercises in a track"

    def award_to?(user)
      user.user_tracks.joins(:track).
        where('tracks.active').
        any? { |ut| ut.completed_percentage == 100 }
    end

    def send_email_on_acquisition? = true
  end
end
