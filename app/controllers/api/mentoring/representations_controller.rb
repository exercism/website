module API
  class Mentoring::RepresentationsController < BaseController
    def without_feedback
      render json: AssembleExerciseRepresentationsWithoutFeedback.(
        current_user, params.permit(*AssembleExerciseRepresentationsWithoutFeedback.keys)
      )
    end

    def with_feedback
      render json: AssembleExerciseRepresentationsWithFeedback.(
        current_user, params.permit(*AssembleExerciseRepresentationsWithFeedback.keys)
      )
    end

    def tracks_without_feedback
      representations = Exercise::Representation::Search.(
        user: current_user, status: :without_feedback, sorted: false, paginated: false
      )

      render json: AssembleRepresentationTracksForSelect.(representations)
    end

    def tracks_with_feedback
      representations = Exercise::Representation::Search.(
        user: current_user, status: :with_feedback, sorted: false, paginated: false
      )

      render json: AssembleRepresentationTracksForSelect.(representations)
    end
  end
end
