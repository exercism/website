module API
  class Solutions::SubmissionAIHelpController < BaseController
    def create
      begin
        submission = Submission.find_by!(uuid: params[:submission_uuid])
      rescue ActiveRecord::RecordNotFound
        return render_submission_not_found
      end

      return render_submission_not_accessible unless submission.solution.user_id == current_user.id

      if submission.ai_help_records.exists?
        Thread.new do
          sleep(2)
          Submission::AIHelpRecordsChannel.broadcast!(submission.ai_help_records.last, submission.uuid)
        end
      else
        Submission::AI::ChatGPT::RequestHelp.(submission)
      end

      render json: {}
    end
  end
end
