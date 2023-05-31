class Payments::Stripe::PaymentIntent::HandleInvoiceFailure
  include Mandate

  initialize_with id: nil, invoice: nil do
    raise "Specify either id or invoice" unless id || invoice
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
    number_of_failed_invoices_in_last_24_hours >= MINIMUM_FAILED_INVOICES_IN_LAST_24_HOURS
  end

  def number_of_failed_invoices_in_last_24_hours
    Stripe::Charge.search(
      query: %(customer:"#{user.stripe_customer_id}" AND status:"failed" AND created>#{(Time.current - 24.hours).to_i}),
      limit: MINIMUM_FAILED_INVOICES_IN_LAST_24_HOURS
    ).count
  end

  memoize
  def user
    raise "No customer in the invoice" unless invoice.customer

    User.with_data.find_by(data: { stripe_customer_id: invoice.customer })
  end

  MINIMUM_FAILED_INVOICES_IN_LAST_24_HOURS = 3
  private_constant :MINIMUM_FAILED_INVOICES_IN_LAST_24_HOURS
end
