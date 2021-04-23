module API
  class Solutions::MentorDiscussionsController < BaseController
    before_action :use_mentor_discussion

    # TODO
    def finish
      @discussion.student_finished!

      if params[:requeue]
        comment = @discussion.request&.comment_markdown || "[No comment provided]"
        Mentor::Request::Create.(@discussion.solution, comment)
      end

      # TODO: Create testimonial
      # TODO: Create abuse report
      # TODO: Store rating
      # TODO: Block user if appropriate
      # TODO: Move all this ^^ into its own service

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
