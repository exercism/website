module API
  class Mentoring::StudentsController < BaseController
    before_action :use_student

    def favorite
      # Both of these lines should return the same error so we don't
      # leak whether handles exist or not
      Mentor::StudentRelationship::ToggleFavorited.(current_user, @student, true)
      render_relationship
    rescue StandardError
      render_400(:invalid_mentor_student_relationship)
    end

    def unfavorite
      # See comment in create
      Mentor::StudentRelationship::ToggleFavorited.(current_user, @student, false)
      render_relationship
    rescue StandardError
      render_400(:invalid_mentor_student_relationship)
    end

    def block
      # Both of these lines should return the same error so we don't
      # leak whether handles exist or not
      Mentor::StudentRelationship::ToggleBlockedByMentor.(current_user, @student, true)
      render_relationship
    rescue StandardError
      render_400(:invalid_mentor_student_relationship)
    end

    def unblock
      Mentor::StudentRelationship::ToggleBlockedByMentor.(current_user, @student, false)
      render_relationship
    rescue StandardError
      render_400(:invalid_mentor_student_relationship)
    end

    private
    def use_student
      @student = User.find_by!(handle: params[:id])
    rescue StandardError
      render_400(:invalid_mentor_student_relationship)
    end

    def render_relationship
      relationship = Mentor::StudentRelationship.find_by!(mentor: current_user, student: @student)
      render json: {
        relationship: SerializeMentorStudentRelationship.(relationship),
        student: SerializeStudent.(@student, current_user)
      }
    rescue StandardError
      render_400(:invalid_mentor_student_relationship)
    end
  end
end
