class Badges::SupermentorBadge < Badge
  seed 'Supermentor',
    :legendary,
    'supermentor',
    'Mentored 100 students on any track'

  def award_to?(user) = user.supermentor?
  def send_email_on_acquisition? = true
end
