class Track::Trophies::General::MentoredTrophy < Track::Trophy
  def name(_) = "Magnificent Mentee"
  def icon = 'trophy-mentored'

  def criteria(track)
    "Awarded once you complete a mentoring session in %<track_title>s" % { track_title: track.title }
  end

  def success_message(track)
    "Congratulations on completing a mentoring session in %<track_title>s" % { track_title: track.title }
  end

  def award?(user, track)
    Mentor::Discussion.finished.joins(:request).where(request: { student: user, track: }).exists?
  end

  def send_email_on_acquisition? = true
end
