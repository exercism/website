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

  def all
    @communication_preferences.update!(
      email_on_mentor_started_discussion_notification: false,
      email_on_mentor_replied_to_discussion_notification: false,
      email_on_student_replied_to_discussion_notification: false,
      email_on_student_added_iteration_notification: false,
      email_on_new_solution_comment_for_solution_user_notification: false,
      email_on_new_solution_comment_for_other_commenter_notification: false,
      receive_product_updates: false,
      email_on_remind_mentor: false,
      email_on_mentor_heartbeat: false,
      email_on_general_update_notification: false,
      email_on_acquired_badge_notification: false,
      email_on_nudge_notification: false,
      email_on_student_finished_discussion_notification: false,
      email_on_mentor_finished_discussion_notification: false,
      email_on_automated_feedback_added_notification: false,
      email_about_fundraising_campaigns: false
    )

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
