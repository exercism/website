module API
  class Mentoring::AutomationController < BaseController
    def with_feedback
      render json: AssembleExerciseRepresentationsWithFeedbackList.(
        current_user,
        params.permit(*AssembleExerciseRepresentationsWithFeedbackList.keys)
      )
    end

    def without_feedback
      render json: AssembleExerciseRepresentationsWithoutFeedbackList.(
        current_user,
        params.permit(*AssembleExerciseRepresentationsWithoutFeedbackList.keys)
      )
    end
  end
end
