class Badges::SlimlineSeptemberBadge < Badge
  TRACK_SLUGS = %w[8th awk bash jq perl5 raku].freeze

  seed "Slimline September",
    :rare,
    'badge-slimline-september',
    'Completed and published five exercises in a concise language in September'

  def self.worth_queuing?(exercise:)
    return false if exercise.tutorial?

    TRACK_SLUGS.include?(exercise.track.slug)
  end

  def award_to?(user)
    user.solutions.published.joins(exercise: :track).
      where('tracks.slug': TRACK_SLUGS).
      where('
              (MONTH(published_at) = 8 AND DAY(published_at) = 31) OR
              (MONTH(published_at) = 9) OR
              (MONTH(published_at) = 10 AND DAY(published_at) = 1)
            ').
      where.not('exercises.slug': 'hello-world').
      count >= 5
  end

  def send_email_on_acquisition? = true
end
