class API::Solutions::AssistantConversationsController < API::BaseController
  before_action :use_solution!

  def create
    return render_403(:invalid_captcha) unless verified_captcha?

    token = Solution::AssistantConversation::CreateConversationToken.(@solution)
    render json: { token: }
  rescue AssistantConversationAccessDeniedError
    render_403(:assistant_conversation_not_accessible)
  end

  def user_messages
    Solution::AssistantConversation::AddUserMessage.(
      @solution,
      params[:content],
      params[:timestamp]
    )
    render json: {}
  end

  def assistant_messages
    Solution::AssistantConversation::AddAssistantMessage.(
      @solution,
      params[:content],
      params[:timestamp],
      params[:signature]
    )
    render json: {}
  rescue InvalidHMACSignatureError
    render_error(401, :invalid_signature)
  end

  private
  def use_solution!
    @solution = Solution.find_by!(uuid: params[:solution_uuid])
    render_solution_not_accessible unless @solution.user_id == current_user.id
  rescue ActiveRecord::RecordNotFound
    render_solution_not_found
  end

  def verified_captcha?
    return false if params[:cf_turnstile_response].blank?

    Captcha::VerifyTurnstileToken.(params[:cf_turnstile_response], remote_ip: request.remote_ip)
  end
end
