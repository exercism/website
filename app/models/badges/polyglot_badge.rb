module Badges
  class PolyglotBadge < Badge
    seed "Polyglot",
      :legendary,
      'badge-polyglot',
      'Completed and published 5 exercises in 12 languages in a single year'

    def award_to?(user)
      user.solutions.published.joins(:exercise).
        group('YEAR(published_at)', :track_id).
        count.
        filter_map { |(year, _), count| year if count >= NUM_PUBLISHED_EXERCISES_PER_TRACK }.
        tally.
        any? { |_, value| value >= NUM_TRACKS_PER_YEAR }
    end

    def send_email_on_acquisition? = true

    NUM_PUBLISHED_EXERCISES_PER_TRACK = 5
    NUM_TRACKS_PER_YEAR = 12
    private_constant :NUM_PUBLISHED_EXERCISES_PER_TRACK, :NUM_TRACKS_PER_YEAR
  end
end
