module Badges
  class FunctionalFebruaryBadge < Badge
    TRACK_SLUGS = %w[
      clojure elixir erlang fsharp haskell ocaml scala sml gleam
    ].freeze

    seed "Functional February",
      :rare,
      'functional',
      'Completed and published five exercises in a functional language in February'

    def self.worth_queuing?(exercise:)
      return false if exercise.tutorial?

      TRACK_SLUGS.include?(exercise.track.slug)
    end

    def award_to?(user)
      user.solutions.published.joins(exercise: :track).
        where('tracks.slug': TRACK_SLUGS).
        where('
                (MONTH(published_at) = 1 AND DAY(published_at) = 31) OR
                (MONTH(published_at) = 2) OR
                (MONTH(published_at) = 3 AND DAY(published_at) = 1)
              ').
        where.not('exercises.slug': 'hello-world').
        count >= 5
    end

    def send_email_on_acquisition? = true
  end
end
