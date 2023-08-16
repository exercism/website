class Track::Trophies::FunctionalTrophy < Track::Trophy
  # TODO: define the tracks for which this is valid, we'll use
  # a dummy track for now to have it apply to none of the tracks
  def self.valid_track_slugs = ['NONE']

  def name(_) = "Functional Familiarity"
  def icon = 'trophy-mentored'
  def criteria(_) = "Awarded for completing 10 functional exercises. Choose from A,b,c,de,f... "

  def success_message(track)
    "Congratulations on completing 10 functional exercises in %<track_title>s" % { track_title: track.title }
  end

  def award?(user, track)
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
