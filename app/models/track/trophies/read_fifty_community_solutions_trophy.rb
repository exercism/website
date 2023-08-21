class Track::Trophies::ReadFiftyCommunitySolutionsTrophy < Track::Trophy
  def name(_) = "Studious Student"
  def icon = 'trophy-read-fifty-community-solutions'
  def order = 5

  # rubocop:disable Layout/LineLength
  def criteria(track)
    "Awarded for reading %<num_solutions>i %<track_title>s community solutions" % {
      num_solutions: NUM_SOLUTIONS,
      track_title: track.title
    }
  end

  def success_message(track)
    "Congratulations on reading %<num_solutions>i community solutions in %<track_title>s. Learning from others is a fantastic way to master a language!" % {
      num_solutions: NUM_SOLUTIONS,
      track_title: track.title
    }
  end
  # rubocop:enable Layout/LineLength

  def award?(user, track)
    UserTrack::ViewedCommunitySolution.
      where(user:, track:).
      count >= NUM_SOLUTIONS
  end

  NUM_SOLUTIONS = 50
  private_constant :NUM_SOLUTIONS
end
