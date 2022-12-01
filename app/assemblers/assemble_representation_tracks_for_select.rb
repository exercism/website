class AssembleRepresentationTracksForSelect
  include Mandate

  initialize_with :mentor, with_feedback: Mandate::NO_DEFAULT

  def call
    tracks.map do |track|
      SerializeTrackForSelect.(track).merge(num_submissions: track_num_representations[track.id])
    end
  end

  private
  memoize
  def tracks
    Track.where(id: track_ids_with_representation).
      where(id: track_ids_with_min_num_mentored_solutions).
      order(title: :asc)
  end

  def track_ids_with_representation = track_num_representations.keys
  def track_ids_with_min_num_mentored_solutions = track_num_mentored_solutions.keys

  memoize
  def track_num_representations = representations.group(:track_id).count

  memoize
  def track_num_mentored_solutions
    mentor.mentor_discussions.
      joins(:request).
      finished_for_student.
      having('COUNT(*) >= ?', Mentor::Supermentor::MIN_NUM_SOLUTIONS_MENTORED_PER_TRACK).
      group(:track_id).
      count
  end

  memoize
  def representations
    Exercise::Representation::Search.(mentor:, with_feedback:, sorted: false, paginated: false)
  end
end
