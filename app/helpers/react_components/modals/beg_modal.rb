module ReactComponents
  module Modals
    class BegModal < ReactComponent
      def to_s
        return unless show_modal?

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
            success: Exercism::Routes.donated_url
          }
        })
      end

      memoize
      def show_modal?
        return false if current_user.current_subscription
        return false if current_user.donated_in_last_35_days?

        dismissal = current_user.dismissed_introducers.find_by(slug: "beg-modal")
        return true unless dismissal

        if dismissal.created_at < 1.month.ago
          dismissal.destroy
          return true
        end

        false
      end

      memoize
      def previous_donor = current_user.total_donated_in_dollars.positive?
    end
  end
end
