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
      ts = mentor.staff? ? Track.all :
        Track.where(id: mentor.track_mentorships.automator.select(:track_id))

      ts.order(title: :asc).filter_map do |track|
        next unless track_num_representations.key?(track.id)

        SerializeTrackForSelect.(track).merge(num_submissions: track_num_representations[track.id])
      end
    end

    def representation_count
      # TODO: This is a hack. I'm not sure how we actually achieve this
      # as we want to filter using a different value for each track.
      representer_version = nil
      representations = Exercise::Representation::Search.(
        mode:,
        representer_version:,
        mentor:,
        sorted: false,
        paginated: false,
        track: search_tracks
      )
      representations.count
    end

    memoize
    def track_num_representations
      # TODO: This is a hack. I'm not sure how we actually achieve this
      # as we want to filter using a different value for each track.
      representer_version = nil
      Exercise::Representation::Search.(
        mode:, representer_version:, mentor:, track: search_tracks,
        sorted: false, paginated: false
      ).
        group(:track_id).
        count
    end

    memoize
    def search_tracks
      mentor.staff? ? :all :
        mentor.track_mentorships.automator.includes(:track).select(:track_id).map(&:track_id)
    end
  end
end
