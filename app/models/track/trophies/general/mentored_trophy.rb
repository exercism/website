class Track::Trophies::General::MentoredTrophy < Track::Trophy
  def name(_) = "Magnificent Mentee"
  def icon = 'trophy-mentored'

  def criteria(track)
    "Awarded once you complete a mentoring session in %<track_title>s" % { track_title: track }
  end

  def success_message(track)
    "Congratulations on completing a mentoring session in %<track_title>s" % { track_title: track }
  end

  def award?(user_track)
    Mentor::Discussion.finished.joins(:request).where(request: { student: user_track.user, track: user_track.track }).exists?
  end

  # def name(track)
  #   TRACK_NAMES[track.slug.to_sym] || FALLBACK_NAME % { track_title: track.title }
  # end

  # TRACK_NAMES = {
  #   ruby: 'X Marks the Spot'
  # }
  # FALLBACK_NAME = "Magnificent Mentee"
end
