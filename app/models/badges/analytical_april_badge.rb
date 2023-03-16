module Badges
  class AnalyticalAprilBadge < Badge
    TRACK_SLUGS = %w[julia python r].freeze

    seed "Analytical April",
      :ultimate,
      'badge-machine-code',
      'Completed and published five exercises in an analytical language in April'

    def self.worth_queuing?(exercise:)
      return false if exercise.tutorial?

      TRACK_SLUGS.include?(exercise.track.slug)
    end

    def award_to?(user)
      user.solutions.published.joins(exercise: :track).
        where('tracks.slug': TRACK_SLUGS).
        where('MONTH(published_at) = 4').
        where.not('exercises.slug': 'hello-world').
        count >= 5
    end

    def send_email_on_acquisition? = true
  end
end
