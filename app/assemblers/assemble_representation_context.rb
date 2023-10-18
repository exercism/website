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
      # TODO: This is a hack. I'm not sure how we actually achieve this
      # as we want to filter using a different value for each track.
      representer_version = nil
      representations = Exercise::Representation::Search.(
        mode:,
        representer_version:,
        mentor:,
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
      # TODO: This is a hack. I'm not sure how we actually achieve this
      # as we want to filter using a different value for each track.
      representer_version = nil
      Exercise::Representation::Search.(
        mode:, representer_version:, mentor:, track: automator_tracks,
        sorted: false, paginated: false
      ).
        group(:track_id).
        count
    end
  end
end
