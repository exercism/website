class Badges::SummerOfSexpsBadge < Badge
  TRACK_SLUGS = %w[clojure clojurescript common-lisp emacs-lisp lfe racket scheme].freeze

  seed "Summer of Sexps",
    :rare,
    'badge-summer-of-sexps',
    'Completed and published five exercises in a Lisp dialect in June'

  def self.worth_queuing?(exercise:)
    return false if exercise.tutorial?

    TRACK_SLUGS.include?(exercise.track.slug)
  end

  def award_to?(user)
    user.solutions.published.joins(exercise: :track).
      where('tracks.slug': TRACK_SLUGS).
      where('
              (MONTH(published_at) = 5 AND DAY(published_at) = 31) OR
              (MONTH(published_at) = 6) OR
              (MONTH(published_at) = 7 AND DAY(published_at) = 1)
            ').
      where.not('exercises.slug': 'hello-world').
      count >= 5
  end

  def send_email_on_acquisition? = true
end
