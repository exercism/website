class Track::Trophies::MentoredTrophy < Track::Trophy
  def name(_) = "Magnificent Mentee"
  def icon = 'trophy-mentored'
  def order = 4

  # rubocop:disable Layout/LineLength
  def criteria(track)
    "Awarded once you complete a mentoring session in %<track_title>s" % { track_title: track.title }
  end

  def success_message(track)
    "Congratulations on completing a mentoring session in %<track_title>s. Our mentors are always here to help and guide you!" % { track_title: track.title }
  end
  # rubocop:enable Layout/LineLength

  def award?(user, track)
    Mentor::Discussion.joins(:request).where(status: %i[finished student_timed_out], request: { student: user, track: }).exists?
  end
end
