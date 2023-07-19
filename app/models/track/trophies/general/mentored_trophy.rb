class Track::Trophies::General::MentoredTrophy < Track::Trophy
  self.valid_track_slugs = []

  def name = "Mentored"
  def icon = 'trophy-mentored'
  def criteria = "Awarded once you complete a mentoring session in %<track>s"
  def success_message = "Congratulations on completing a mentoring session in %<track>s"

  def award?(user, track)
    Mentor::Discussion.finished.joins(:request).where(request: { student: user, track: }).exists?
  end
end
