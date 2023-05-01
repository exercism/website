module Badges
  class MindShiftingMayBadge < Badge
    TRACK_SLUGS = %w[ballerina pharo-smalltalk prolog red rust tcl unison].freeze

    seed "Mindshifting May",
      :rare,
      'badge-mind-shifting-may',
      'Completed and published five exercises in a mindshifting language in May'

    def self.worth_queuing?(exercise:)
      return false if exercise.tutorial?

      TRACK_SLUGS.include?(exercise.track.slug)
    end

    def award_to?(user)
      user.solutions.published.joins(exercise: :track).
        where('tracks.slug': TRACK_SLUGS).
        where('
                (MONTH(published_at) = 4 AND DAY(published_at) = 30) OR
                (MONTH(published_at) = 5) OR
                (MONTH(published_at) = 6 AND DAY(published_at) = 1)
              ').
        where.not('exercises.slug': 'hello-world').
        count >= 5
    end

    def send_email_on_acquisition? = true
  end
end
