class Track::Trophies::ReadFiftyCommunitySolutionsTrophy < Track::Trophy
  def name(_) = "Studious Student"
  def icon = 'trophy-read-fifty-community-solutions'
  def order = 5

  def criteria(track)
    "Awarded once you've read %<num_solutions>i community solutions in %<track_title>s" % {
      num_solutions: NUM_SOLUTIONS,
      track_title: track.title
    }
  end

  def success_message(track)
    "Congratulations on reading %<num_solutions>i community solutions in %<track_title>s" % {
      num_solutions: NUM_SOLUTIONS,
      track_title: track.title
    }
  end

  def award?(user, track)
    UserTrack::ViewedCommunitySolution.
      where(user:, track:).
      count >= NUM_SOLUTIONS
  end

  def send_email_on_acquisition? = true

  NUM_SOLUTIONS = 50
  private_constant :NUM_SOLUTIONS
end
