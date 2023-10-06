class AssembleRepresentationContext
  include Mandate

  initialize_with :mentor

  def call
    {
      without_feedback: AssembleRepresentationContextForMode.(mentor, mode: :without_feedback),
      with_feedback: AssembleRepresentationContextForMode.(mentor, mode: :with_feedback),
      admin: AssembleRepresentationContextForMode.(mentor, mode: :admin)
    }
  end

  class AssembleRepresentationContextForMode
    include Mandate

    initialize_with :mentor, mode: Mandate::NO_DEFAULT

    def call = { tracks:, representation_count: }

    private
    def tracks
      automator_tracks.filter_map do |track|
        next unless track_num_representations.key?(track.id)

        SerializeTrackForSelect.(track).merge(num_submissions: track_num_representations[track.id])
      end
    end

    def representation_count
      representations = Exercise::Representation::Search.(
        mentor:,
        mode:,
        sorted: false,
        paginated: false,
        track: automator_tracks
      )
      representations.count
    end

    memoize
    def automator_tracks
      return Track.all.order(title: :asc) if mentor.staff?

      Track.where(id: mentor.track_mentorships.automator.select(:track_id)).order(title: :asc)
    end

    memoize
    def track_num_representations
      Exercise::Representation::Search.(mentor:, mode:, sorted: false, paginated: false,
        track: automator_tracks).
        group(:track_id).
        count
    end
  end
end
