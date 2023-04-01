module Badges
  class MechanicalMarchBadge < Badge
    TRACK_SLUGS = %w[c cpp d go nim rust vlang zig].freeze

    seed "Mechanical March",
      :rare,
      'badge-machine-code',
      'Completed and published five exercises in a systems language in March'

    def self.worth_queuing?(exercise:)
      return false if exercise.tutorial?

      TRACK_SLUGS.include?(exercise.track.slug)
    end

    def award_to?(user)
      user.solutions.published.joins(exercise: :track).
        where('tracks.slug': TRACK_SLUGS).
        where('
                (MONTH(published_at) = 2 AND (DAY(published_at) = 28 OR DAY(published_at) = 29)) OR
                (MONTH(published_at) = 3) OR
                (MONTH(published_at) = 4 AND DAY(published_at) = 1)
              ').
        where.not('exercises.slug': 'hello-world').
        count >= 5
    end

    def send_email_on_acquisition? = true
  end
end
