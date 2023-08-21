class Track::Trophies::CompletedLearningModeTrophy < Track::Trophy
  def self.valid_track_slugs = Track.active.where(course: true).pluck(:slug)

  def name(_) = "Fundamental"
  def icon = 'trophy-completed-learning-mode'

  def criteria(track)
    "Awarded once you complete Learning Mode in %<track_title>s" % { track_title: track.title }
  end

  def success_message(track)
    "Congratulations on completing Learning Mode in %<track_title>s" % { track_title: track.title }
  end

  def award?(user, track)
    UserTrack.for(user, track).completed_course?
  end
end
