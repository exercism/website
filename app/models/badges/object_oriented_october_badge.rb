class Badges::ObjectOrientedOctoberBadge < Badge
  TRACK_SLUGS = %w[crystal csharp java pharo-smalltalk ruby powershell].freeze

  seed "Object-Oriented October",
    :rare,
    'badge-object-oriented-october',
    'Completed and published five exercises in an object-oriented language in October'

  def self.worth_queuing?(exercise:)
    return false if exercise.tutorial?

    TRACK_SLUGS.include?(exercise.track.slug)
  end

  def award_to?(user)
    user.solutions.published.joins(exercise: :track).
      where('tracks.slug': TRACK_SLUGS).
      where('(MONTH(published_at) = 9 AND DAY(published_at) = 30) OR
             (MONTH(published_at) = 10) OR
             (MONTH(published_at) = 11 AND DAY(published_at) = 1)').
      where.not('exercises.slug': 'hello-world').
      count >= 5
  end

  def send_email_on_acquisition? = true
end
