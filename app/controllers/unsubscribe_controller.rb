class UnsubscribeController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :guard_token!
  before_action :guard_key!

  def show; end

  def update
    if params[:communication_preferences].present?
      @communication_preferences.update(
        params.require(:communication_preferences).reject do |k, _v|
          %w[user_id created_at updated_at token].include?(k)
        end.permit!
      )
    end

    redirect_to({ action: :show, token: @token, key: @email_key }, notice: "You have been unsubscribed successfully")
  end

  private
  def guard_token!
    @token = params[:token]
    return redirect_to communication_preferences_settings_path unless @token

    begin
      @communication_preferences = User::CommunicationPreferences.find_by!(token: @token)
    rescue StandardError
      redirect_to communication_preferences_settings_path
    end
  end

  def guard_key!
    @email_key = params[:key]
    redirect_to communication_preferences_settings_path unless @email_key
  end
end
