class Badges::SupermentorBadge < Badge
  seed 'Supermentor',
    :legendary,
    'supermentor',
    'Finshed 100 mentoring sessions'

  def award_to?(user) = user.supermentor?
  def send_email_on_acquisition? = true
end
