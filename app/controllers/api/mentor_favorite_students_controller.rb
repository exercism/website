module API
  class MentorFavoriteStudentsController < BaseController
    def create
      # Both of these lines should return the same error so we don't
      # leak whether handles exist or not
      student = User.find_by!(handle: params[:student_handle])
      Mentor::StudentRelationship::ToggleFavorite.(current_user, student, true)
      render json: {}, status: :ok
    rescue StandardError
      render_400(:invalid_mentor_student_relationship)
    end

    def destroy
      # See comment in create
      student = User.find_by!(handle: params[:student_handle])
      Mentor::StudentRelationship::ToggleFavorite.(current_user, student, false)
      render json: {}, status: :ok
    rescue StandardError
      render_400(:invalid_mentor_student_relationship)
    end
  end
end
