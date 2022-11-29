module Donations
  module PaymentIntent
    class HandleInvoiceFailure
      include Mandate

      def initialize(id: nil, invoice: nil)
        raise "Specify either id or invoice" unless id || invoice

        @id = id
        @invoice = invoice
      end

      # We guard against spammers here
      def call
        return unless user
        return unless user.stripe_customer_id.present?
        return if user.uid # Return if the user has auth'd via GitHub

        has_three_failed_invoiced_today = Stripe::Charge.search(
          query: %(customer:"#{user.stripe_customer_id}" AND status:"failed" AND created>#{(Time.current - 24.hours).to_i}),
          limit: 3
        ).count == 3

        user.update!(disabled_at: Time.current) if has_three_failed_invoiced_today
      end

      private
      attr_reader :id, :invoice

      memoize
      def user
        raise "No customer in the invoice" unless invoice.customer

        User.find_by(stripe_customer_id: invoice.customer)
      end
    end
  end
end
