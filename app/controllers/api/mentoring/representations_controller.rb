module API
  class Mentoring::RepresentationsController < BaseController
    before_action :ensure_supermentor!
    before_action :use_representation, only: :update

    def update
      if Exercise::Representation::SubmitFeedback.(@current_user, @representation, update_params[:feedback_markdown],
        update_params[:feedback_type])
        render json: { representation: SerializeExerciseRepresentation.(@representation) }
      else
        render_400(:failed_validations, errors: @representation.errors)
      end
    end

    def without_feedback
      render json: AssembleExerciseRepresentationsWithoutFeedback.(current_user, without_feedback_params)
    end

    def with_feedback
      render json: AssembleExerciseRepresentationsWithFeedback.(current_user, with_feedback_params)
    end

    def admin
      render json: AssembleExerciseRepresentationsAdmin.(current_user, admin_params)
    end

    def tracks_without_feedback
      render json: AssembleRepresentationTracksForSelect.(current_user, mode: :without_feedback)
    end

    def tracks_with_feedback
      render json: AssembleRepresentationTracksForSelect.(current_user, mode: :with_feedback)
    end

    private
    def use_representation
      @representation = Exercise::Representation.find_by!(uuid: params[:uuid])

      render_403(:not_supermentor_for_track) unless Mentor::Supermentor.for_track?(current_user, @representation.track)
    rescue ActiveRecord::RecordNotFound
      render_404(:representation_not_found)
    end

    def without_feedback_params
      params.permit(*AssembleExerciseRepresentationsWithoutFeedback.keys)
    end

    def with_feedback_params
      params.permit(*AssembleExerciseRepresentationsWithFeedback.keys)
    end

    def admin_params
      params.permit(*AssembleExerciseRepresentationsAdmin.keys)
    end

    def update_params
      params.require(:representation).permit(:feedback_markdown, :feedback_type)
    end
  end
end
