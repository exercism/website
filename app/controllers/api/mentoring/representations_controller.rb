module API
  class Mentoring::RepresentationsController < BaseController
    def without_feedback
      render json: AssembleExerciseRepresentationsWithoutFeedback.(
        current_user,
        params.permit(*AssembleExerciseRepresentationsWithoutFeedback.keys)
      )
    end

    def with_feedback
      render json: AssembleExerciseRepresentationsWithFeedback.(
        current_user,
        params.permit(*AssembleExerciseRepresentationsWithFeedback.keys)
      )
    end

    def tracks_without_feedback
      # TODO: consider how to fetch this here _and_ in the react component
      # without duplicating code
      track_representation_counts = Exercise::Representation::Search.(
        track: current_user.mentored_tracks,
        status: :without_feedback,
        sorted: false,
        paginated: false
      ).group(:track_id).count
      tracks = current_user.mentored_tracks

      render_tracks(tracks, track_representation_counts)
    end

    def tracks_with_feedback
      track_representation_counts = Exercise::Representation::Search.(
        user: current_user,
        status: :with_feedback,
        sorted: false,
        paginated: false
      ).group(:track_id).count
      tracks = Track.where(id: track_representation_counts.keys)

      render_tracks(tracks, track_representation_counts)
    end

    private
    def render_tracks(tracks, track_representation_counts)
      # TODO: make this a special serializer
      data = tracks.order(:title).map do |track|
        SerializeTrackForSelect.(track).merge(num_submissions: track_representation_counts[track.id])
      end

      render json: [
        SerializeTrackForSelect::ALL_TRACK.merge(num_submissions: track_representation_counts.values.sum),
        *data
      ]
    end
  end
end
