class Badges::DecemberDiversionsBadge < Badge
  TRACK_SLUGS = %w[cfml groovy lua vimscript wren].freeze

  seed "December Diversions",
    :rare,
    'badge-december-diversions',
    'Completed and published five exercises in a December Diversions language'

  def self.worth_queuing?(exercise:)
    return false if exercise.tutorial?

    TRACK_SLUGS.include?(exercise.track.slug)
  end

  def award_to?(user)
    user.solutions.published.joins(exercise: :track).
      where('tracks.slug': TRACK_SLUGS).
      where('
              (MONTH(published_at) = 11 AND DAY(published_at) = 30) OR
              (MONTH(published_at) = 12) OR
              (MONTH(published_at) = 1 AND DAY(published_at) = 1)
            ').
      where.not('exercises.slug': 'hello-world').
      count >= 5
  end

  def send_email_on_acquisition? = true
end
