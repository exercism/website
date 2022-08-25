module API
  class Mentoring::RepresentationsController < BaseController
    before_action :ensure_supermentor!
    before_action :use_representation, only: %i[show update]

    def show
      render json: {
        representation: SerializeExerciseRepresentation.(@representation)
      }
    end

    def update
      if @representation.update(update_params)
        render json: {
          representation: SerializeExerciseRepresentation.(@representation)
        }
      else
        render json: {}, status: :unprocessable_entity
      end
    end

    def without_feedback
      render json: AssembleExerciseRepresentationsWithoutFeedback.(current_user, without_feedback_params)
    end

    def with_feedback
      render json: AssembleExerciseRepresentationsWithFeedback.(current_user, with_feedback_params)
    end

    def tracks_without_feedback
      render json: AssembleRepresentationTracksForSelect.(current_user, with_feedback: false)
    end

    def tracks_with_feedback
      render json: AssembleRepresentationTracksForSelect.(current_user, with_feedback: true)
    end

    private
    def use_representation
      @representation = Exercise::Representation.find_by!(uuid: params[:uuid])
    rescue ActiveRecord::RecordNotFound
      render_404(:representation_not_found)
    end

    def without_feedback_params
      params.permit(*AssembleExerciseRepresentationsWithoutFeedback.keys)
    end

    def with_feedback_params
      params.permit(*AssembleExerciseRepresentationsWithFeedback.keys)
    end

    def create_params
      params.require(:representation).permit(:feedback_markdown, :feedback_type)
    end

    def update_params
      params.require(:representation).permit(:feedback_markdown, :feedback_type)
    end
  end
end
