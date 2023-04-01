module Badges
  class AnalyticalAprilBadge < Badge
    TRACK_SLUGS = %w[julia python r].freeze

    seed "Analytical April",
      :rare,
      'badge-analytical-april',
      'Completed and published five exercises in an analytical language in April'

    def self.worth_queuing?(exercise:)
      return false if exercise.tutorial?

      TRACK_SLUGS.include?(exercise.track.slug)
    end

    def award_to?(user)
      user.solutions.published.joins(exercise: :track).
        where('tracks.slug': TRACK_SLUGS).
        where('
                (MONTH(published_at) = 3 AND DAY(published_at) = 31) OR
                (MONTH(published_at) = 4) OR
                (MONTH(published_at) = 5 AND DAY(published_at) = 1)
              ').
        where.not('exercises.slug': 'hello-world').
        count >= 5
    end

    def send_email_on_acquisition? = true
  end
end
