module API
  class Solutions::MentorDiscussionsController < BaseController
    before_action :use_mentor_discussion

    # TODO
    def finish
      @discussion.update!(finished_at: Time.current)

      # TODO
      Mentor::Request::Create.(@discussion.solution, "temp comment") if params[:requeue]

      render json: {}
    end

    private
    def use_mentor_discussion
      @discussion = Mentor::Discussion.find_by(uuid: params[:id])
      return render_404(:mentor_discussion_not_found) unless @discussion

      @solution = @discussion.solution
      return render_403(:mentor_discussion_not_accessible) unless @solution.user_id == current_user.id
    end
  end
end
