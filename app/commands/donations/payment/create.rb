module Donations
  class Payment
    class Create
      include Mandate

      def initialize(user, stripe_data, subscription: nil)
        @user = user
        @stripe_data = stripe_data
        @subscription = subscription
      end

      def call
        Donations::Payment.create_or_find_by!(
          user: user,
          stripe_id: stripe_data.id
        ) do |payment|
          payment.subscription = subscription
          payment.amount_in_cents = stripe_data.amount
        end
      end

      memoize
      def subscription
        return @subscription if @subscription

        return unless stripe_data.invoice

        invoice = Stripe::Invoice.retrieve(stripe_data.invoice)
        return unless invoice.subscription

        begin
          user.donation_subscriptions.find_by!(stripe_id: invoice.subscription)
        rescue ActiveRecord::RecordNotFound
          raise "Subscription not yet created. Wait for webhook then try again."
        end
      end

      private
      attr_reader :user, :stripe_data
    end
  end
end
