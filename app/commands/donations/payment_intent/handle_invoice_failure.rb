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
        return if user.uid # Return if the user has auth'd via GitHub

        user.update!(disabled_at: Time.current) if too_many_failed_invoices_in_last_24_hours?
      end

      private
      attr_reader :id, :invoice

      def too_many_failed_invoices_in_last_24_hours?
        number_of_failed_invoices_in_last_24_hours == 3
      end

      def number_of_failed_invoices_in_last_24_hours
        Stripe::Charge.search(
          query: %(customer:"#{user.stripe_customer_id}" AND status:"failed" AND created>#{(Time.current - 24.hours).to_i}),
          limit: 3
        ).count
      end

      memoize
      def user
        raise "No customer in the invoice" unless invoice.customer

        User.find_by(stripe_customer_id: invoice.customer)
      end
    end
  end
end
