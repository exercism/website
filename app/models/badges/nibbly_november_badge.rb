class Badges::NibblyNovemberBadge < Badge
  TRACK_SLUGS = %w[x86-64-assembly mips wasm].freeze

  seed "Nibbly November",
    :rare,
    'badge-nibbly-november',
    'Completed and published five exercises in an assembly language in November'

  def self.worth_queuing?(exercise:)
    return false if exercise.tutorial?

    TRACK_SLUGS.include?(exercise.track.slug)
  end

  def award_to?(user)
    user.solutions.published.joins(exercise: :track).
      where('tracks.slug': TRACK_SLUGS).
      where('
              (MONTH(published_at) = 10 AND DAY(published_at) = 31) OR
              (MONTH(published_at) = 11) OR
              (MONTH(published_at) = 12 AND DAY(published_at) = 1)
            ').
      where.not('exercises.slug': 'hello-world').
      count >= 5
  end

  def send_email_on_acquisition? = true
end
