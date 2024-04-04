class API::Solutions::MentorRequestsController < API::BaseController
  before_action :use_solution
  before_action :use_mentor_request, only: :update

  def create
    mentor_request = Mentor::Request::Create.(@solution, params[:comment])

    user_track = UserTrack.for(current_user, @solution.track)
    user_track.update!(objectives: params[:track_objectives]) unless user_track.external?

    render json: {
      mentor_request: SerializeMentorSessionRequest.(mentor_request, current_user)
    }
  rescue NoMentoringSlotsAvailableError
    render_400(:no_mentoring_slots_available)
  end

  def update
    if @mentor_request.update(comment_markdown: params[:content])
      render json: {
        item: SerializeMentorDiscussionPost.(@mentor_request.comment, current_user)
      }
    else
      render_400(:failed_validations, errors: @mentor_request.errors)
    end
  end

  private
  def use_solution
    begin
      @solution = Solution.find_by!(uuid: params[:solution_uuid])
    rescue ActiveRecord::RecordNotFound
      return render_solution_not_found
    end

    render_solution_not_accessible unless @solution.user_id == current_user.id
  end

  def use_mentor_request
    @mentor_request = @solution.mentor_requests.find_by!(uuid: params[:uuid])

    render_solution_not_accessible unless @mentor_request.solution.user_id == current_user.id
  end
end
