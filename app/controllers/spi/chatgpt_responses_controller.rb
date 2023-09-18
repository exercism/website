module SPI
  class ChatGPTResponsesController < BaseController
    def create
      Submission::AI::ChatGPT::ProcessRequest.(
        Submission.find_by!(uuid: params[:submission_uuid]),
        params[:type].to_sym,
        params[:chatgpt_version],
        params[:chatgpt_response]
      )
      render json: {}
    end
  end
end
