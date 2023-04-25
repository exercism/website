module SPI
  class ChatGPTResponsesController < BaseController
    def create
      Submission::AI::ChatGPT::ProcessRequest.(
        Submission.find_by!(uuid: params[:submission_uuid]),
        params[:type].to_sym,
        params[:chatgpt_response]
      )
      render json: {}
    end
  end

  def show
    submission_id = params[:submission_id]
    ai_help_record = Submission::AIHelpRecord.find_by(submission_id:)
    if ai_help_record
      render json: ai_help_record, status: :ok
    else
      render json: { error: 'Record not found' }, status: :not_found
    end
  end
end
