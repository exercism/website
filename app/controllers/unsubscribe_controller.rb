class UnsubscribeController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :guard_token!

  def show
    @email_key = params[:key]
    redirect_to communication_preferences_settings_path unless @email_key
  end

  def update
    if params[:communication_preferences].present?
      @preferences.update(
        params.require(:communication_preferences).reject do |k, _v|
          %w[user_id created_at updated_at token].include?(k)
        end.permit!
      )
    end

    redirect_to({ action: :show, token: @token }, notice: "Your communication Preferences have been updated successfully")
  end

  private
  def guard_token!
    @token = params[:token]
    return redirect_to communication_preferences_settings_path if @token.nil?

    begin
      @preferences = User::CommunicationPreferences.find_by!(token: @token)
    rescue StandardError
      redirect_to communication_preferences_settings_path
    end
  end
end
