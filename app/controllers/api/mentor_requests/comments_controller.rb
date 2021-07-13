module API
  module MentorRequests
    class CommentsController < BaseController
      before_action :use_mentor_request

      def update
        if @mentor_request.update(comment_markdown: params[:content])
          render json: {
            post: SerializeMentorDiscussionPost.(@mentor_request.comment, current_user)
          }
        else
          render_400(:failed_validations, errors: @mentor_request.errors)
        end
      end

      private
      def use_mentor_request
        @mentor_request = Mentor::Request.find_by!(uuid: params[:mentor_request_uuid])

        return render_solution_not_accessible unless @mentor_request.solution.user_id == current_user.id
      end
    end
  end
end
