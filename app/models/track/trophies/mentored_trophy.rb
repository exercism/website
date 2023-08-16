class Track::Trophies::MentoredTrophy < Track::Trophy
  def name(_) = "Magnificent Mentee"
  def icon = 'trophy-mentored'
  def order = 4

  def criteria(track)
    "Awarded once you complete a mentoring session in %<track_title>s" % { track_title: track.title }
  end

  def success_message(track)
    "Congratulations on completing a mentoring session in %<track_title>s" % { track_title: track.title }
  end

  def award?(user, track)
    Mentor::Discussion.finished.joins(:request).where(request: { student: user, track: }).exists?
  end
end
