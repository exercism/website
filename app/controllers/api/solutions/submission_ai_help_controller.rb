class API::Solutions::SubmissionAIHelpController < API::BaseController
  def create
    begin
      submission = Submission.find_by!(uuid: params[:submission_uuid])
    rescue ActiveRecord::RecordNotFound
      return render_submission_not_found
    end

    return render_submission_not_accessible unless submission.solution.user_id == current_user.id

    record = submission.ai_help_records.last
    if record
      render json: {
        help_record: SerializeSubmissionAIHelpRecord.(record),
        usage: current_user.chatgpt_usage
      }, status: :ok
    else
      Submission::AI::ChatGPT::RequestHelp.(submission, params[:chatgpt_version])
      render json: {}, status: :accepted
    end
  rescue ChatGPTTooManyRequestsError
    render_error(
      402,
      :too_many_requests,
      usage_type: :chatgpt,
      usage: current_user.chatgpt_usage
    )
  end
end
