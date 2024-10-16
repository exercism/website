class Track::Trophies::ReadFiveApproachesTrophy < Track::Trophy
  def self.valid_track_slugs
    Track.active.where(id:
      Exercise::Approach.joins(:exercise).
        where('exercises.track_id = tracks.id').
        having("count(*) >= ?", NUM_APPROACHES).
        select(:track_id)).pluck(:slug)
  end

  def name(_) = "Digging Deeper"
  def icon = 'trophy-read-five-approaches'
  def order = 7

  # rubocop:disable Layout/LineLength
  def criteria(track)
    "Awarded for reading %<num_approaches>i %<track_title>s approaches" % {
      num_approaches: NUM_APPROACHES,
      track_title: track.title
    }
  end

  def success_message(track)
    "Congratulations on reading %<num_approaches>i approaches in %<track_title>s. Learning how to approach an exercise in different ways is a fantastic way to master a language!" % {
      num_approaches: NUM_APPROACHES,
      track_title: track.title
    }
  end
  # rubocop:enable Layout/LineLength

  def award?(user, track)
    UserTrack::ViewedExerciseApproach.
      where(user:, track:).
      count >= NUM_APPROACHES
  end

  NUM_APPROACHES = 5
  private_constant :NUM_APPROACHES
end
