class Badges::AppsAugustBadge < Badge
  TRACK_SLUGS = %w[abap coffeescript dart delphi elm java javascript kotlin objective-c php purescript reasonml swift
                   typescript].freeze

  seed "Appy August",
    :rare,
    'badge-apps-august',
    'Completed and published five exercises in an App-building language in August'

  def self.worth_queuing?(exercise:)
    return false if exercise.tutorial?

    TRACK_SLUGS.include?(exercise.track.slug)
  end

  def award_to?(user)
    user.solutions.published.joins(exercise: :track).
      where('tracks.slug': TRACK_SLUGS).
      where('
              (MONTH(published_at) = 7 AND DAY(published_at) = 31) OR
              (MONTH(published_at) = 8) OR
              (MONTH(published_at) = 9 AND DAY(published_at) = 1)
            ').
      where.not('exercises.slug': 'hello-world').
      count >= 5
  end

  def send_email_on_acquisition? = true
end
