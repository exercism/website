class API::Mentoring::StudentsController < API::BaseController
  before_action :use_student

  # TODO: (Optional) Add test coverage
  def show
    relationship = Mentor::StudentRelationship.find_by(mentor: current_user, student: @student)
    user_track = UserTrack.for(@student, params[:track_slug]) if params[:track_slug].present?
    render json: {
      student: SerializeStudent.(
        @student,
        current_user,
        user_track:,
        relationship:,
        anonymous_mode: false
      )
    }
  end

  def favorite
    # Both of these lines should return the same error so we don't
    # leak whether handles exist or not
    Mentor::StudentRelationship::ToggleFavorited.(current_user, @student, true)
    render_serialized_student
  rescue StandardError
    render_400(:invalid_mentor_student_relationship)
  end

  def unfavorite
    # See comment in create
    Mentor::StudentRelationship::ToggleFavorited.(current_user, @student, false)
    render_serialized_student
  rescue StandardError
    render_400(:invalid_mentor_student_relationship)
  end

  def block
    # Both of these lines should return the same error so we don't
    # leak whether handles exist or not
    Mentor::StudentRelationship::ToggleBlockedByMentor.(current_user, @student, true)
    render_serialized_student
  rescue StandardError
    render_400(:invalid_mentor_student_relationship)
  end

  def unblock
    Mentor::StudentRelationship::ToggleBlockedByMentor.(current_user, @student, false)
    render_serialized_student
  rescue StandardError
    render_400(:invalid_mentor_student_relationship)
  end

  private
  def use_student
    @student = User.find_by!(handle: params[:handle])
  rescue StandardError
    render_400(:invalid_mentor_student_relationship)
  end

  def render_serialized_student
    relationship = Mentor::StudentRelationship.find_by!(mentor: current_user, student: @student)
    render json: {
      student: SerializeStudent.(
        @student,
        current_user,
        user_track: nil,
        relationship:,
        anonymous_mode: false
      )
    }
  rescue StandardError
    render_400(:invalid_mentor_student_relationship)
  end
end
