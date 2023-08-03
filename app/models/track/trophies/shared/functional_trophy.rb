class Track::Trophies::Shared::FunctionalTrophy < Track::Trophy
  def name(_) = "Functional Familiarity"
  def icon = 'trophy-mentored'
  def criteria(_) = "Awarded for completing 10 functional exercises. Choose from A,b,c,de,f... "

  def success_message(track)
    "Congratulations on completing 10 functional exercises in %<track_title>s" % { track_title: track }
  end

  def award?(user_track)
    # TODO
  end

  # def name(track)
  #   TRACK_NAMES[track.slug.to_sym] || FALLBACK_NAME % { track_title: track.title }
  # end

  # TRACK_NAMES = {
  #   ruby: 'X Marks the Spot'
  # }
  # FALLBACK_NAME = "Magnificent Mentee"
end
