module API
  class Mentoring::RepresentationsController < BaseController
    before_action :ensure_supermentor!

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
      render json: AssembleRepresentationTracksForSelect.(current_user, :without_feedback)
    end

    def tracks_with_feedback
      render json: AssembleRepresentationTracksForSelect.(current_user, :with_feedback)
    end
  end
end
