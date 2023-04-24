module API
  class Solutions::SubmissionAIHelpController < BaseController
    def create
      begin
        submission = Submission.find_by!(uuid: params[:submission_uuid])
      rescue ActiveRecord::RecordNotFound
        return render_submission_not_found
      end

      return render_submission_not_accessible unless submission.solution.user_id == current_user.id

      render json: {
        text: Submission::AI::ChatGPT::RequestHelp.(submission)
      }
    end
  end
end
