class Badges::JurassicJulyBadge < Badge
  TRACK_SLUGS = %w[c cpp cobol fortran vbnet].freeze

  seed "Jurassic July",
    :rare,
    'badge-jurassic-july',
    'Completed and published five exercises in a Jurassic language in July'

  def self.worth_queuing?(exercise:)
    return false if exercise.tutorial?

    TRACK_SLUGS.include?(exercise.track.slug)
  end

  def award_to?(user)
    user.solutions.published.joins(exercise: :track).
      where('tracks.slug': TRACK_SLUGS).
      where('
              (MONTH(published_at) = 6 AND DAY(published_at) = 30) OR
              (MONTH(published_at) = 7) OR
              (MONTH(published_at) = 8 AND DAY(published_at) = 1)
            ').
      where.not('exercises.slug': 'hello-world').
      count >= 5
  end

  def send_email_on_acquisition? = true
end
