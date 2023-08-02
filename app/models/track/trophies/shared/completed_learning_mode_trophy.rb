class Track::Trophies::Shared::CompletedLearningModeTrophy < Track::Trophies::SharedTrophy
  def name(_) = "Fundamental"
  def icon = 'trophy-completed-learning-mode'

  def criteria(track)
    "Awarded once you complete Learning Mode in %<track_title>s" % { track_title: track }
  end

  def success_message(track)
    "Congratulations on completing Learning Mode in %<track_title>s" % { track_title: track }
  end

  def award?(user, track)
    user_track = UserTrack.for!(user, track)
    user_track.completed_course?
  end
end
