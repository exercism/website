class UnsubscribeController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :guard_token!
  before_action :guard_key!

  def show; end

  def update
    if params[:communication_preferences].present?
      prefs = params.require(:communication_preferences).
        permit(*User::CommunicationPreferences.keys)
      prefs.transform_values! { |v| ActiveModel::Type::Boolean.new.cast(v) }
      @communication_preferences.update!(prefs)
    end

    redirect_to({ action: :show, token: @token, key: @email_key }, notice: "You have been unsubscribed successfully")
  end

  def all
    User::UnsubscribeFromAllEmails.(@communication_preferences.user)
    redirect_to({ action: :show, token: @token }, notice: "You have been unsubscribed from all emails successfully")
  end

  private
  def guard_token!
    @token = params[:token]
    return redirect_to communication_preferences_settings_path if @token.blank?

    begin
      @communication_preferences = User::CommunicationPreferences.find_by!(token: @token)
    rescue StandardError
      redirect_to communication_preferences_settings_path
    end
  end

  def guard_key!
    @email_key = params[:key]
    # redirect_to communication_preferences_settings_path unless @email_key
  end
end
