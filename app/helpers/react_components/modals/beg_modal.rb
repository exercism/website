module ReactComponents
  module Modals
    class BegModal < ReactComponent
      def to_s
        return unless show_modal?

        showing_modal!

        super("beg-modal", {
          previous_donor:,
          request: {
            endpoint: Exercism::Routes.current_api_payments_subscriptions_url,
            options: {
              initial_data: AssembleCurrentSubscription.(current_user)
            }
          },
          links: {
            settings: Exercism::Routes.donations_settings_url,
            success: Exercism::Routes.dashboard_url,
            hide_introducer: Exercism::Routes.hide_api_settings_introducer_path(INTRODUCER_SLUG)
          }
        })
      end

      def recently_seen_seniority_modal?
        flag = ReactComponents::Modals::SenioritySurveyModal::SHOWN_AT_FLAG
        flag_value = session[flag]
        return false unless flag_value.present?
        return false if DateTime.parse(flag_value) < 5.minutes.ago

        true
      rescue StandardError
        false
      end

      private
      memoize
      def show_modal?
        return false if showing_modal?
        return false if recently_seen_seniority_modal?
        return false if current_user.current_subscription?
        return false if current_user.donated_in_last_35_days?
        return false unless current_user.solutions.count >= 5
        return false unless current_user.submissions.where('created_at > ?', Time.current - 5.days).exists?

        dismissal = current_user.dismissed_introducers.find_by(slug: INTRODUCER_SLUG)
        return true unless dismissal

        if dismissal.created_at < 1.month.ago
          dismissal.destroy
          return true
        end

        false
      end

      memoize
      def previous_donor = current_user.total_donated_in_dollars.positive?

      INTRODUCER_SLUG = "beg-modal".freeze
      private_constant :INTRODUCER_SLUG
    end
  end
end
