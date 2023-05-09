class Webhooks::ProcessPaypalUpdate
  include Mandate

  initialize_with :event_type, :resource

  def call
    Webhooks::Paypal::Debug.(
      <<~MESSAGE
        [Webhooks::ProcessPaypalUpdate-1]
          Event type: #{event_type}
          Resource: #{resource.to_json}
      MESSAGE
    )

    case event_type
    when "BILLING.SUBSCRIPTION.ACTIVATED", "BILLING.SUBSCRIPTION.RE-ACTIVATED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-2]
            Donations::Paypal::Subscription::HandleActivated.(resource)
        MESSAGE
      )
      Donations::Paypal::Subscription::HandleActivated.(resource)
    when "BILLING.SUBSCRIPTION.CANCELLED", "BILLING.SUBSCRIPTION.EXPIRED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-3]
            Donations::Paypal::Subscription::HandleCancelled.(resource)
        MESSAGE
      )
      Donations::Paypal::Subscription::HandleCancelled.(resource)
    when "BILLING.SUBSCRIPTION.CREATED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-4]
            Donations::Paypal::Subscription::HandleCreated.(resource)#{' '}
        MESSAGE
      )
      Donations::Paypal::Subscription::HandleCreated.(resource)
    when "BILLING.SUBSCRIPTION.PAYMENT.FAILED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-5]
            Donations::Paypal::Subscription::HandlePaymentFailed.(resource)
        MESSAGE
      )
      Donations::Paypal::Subscription::HandlePaymentFailed.(resource)
    when "BILLING.SUBSCRIPTION.UPDATED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-6]
            Donations::Paypal::Subscription::HandleUpdated.(resource)
        MESSAGE
      )
      Donations::Paypal::Subscription::HandleUpdated.(resource)
    when "PAYMENT.SALE.COMPLETED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-7]
            Donations::Paypal::Payment::HandleSaleCompleted.(resource)
        MESSAGE
      )
      Donations::Paypal::Payment::HandleSaleCompleted.(resource)
    when "PAYMENT.SALE.DENIED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-8]
            Donations::Paypal::Payment::HandleSaleDenied.(resource)
        MESSAGE
      )
      Donations::Paypal::Payment::HandleSaleDenied.(resource)
    when "PAYMENT.SALE.REFUNDED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-9]
            Donations::Paypal::Payment::HandleSaleRefunded.(resource)
        MESSAGE
      )
      Donations::Paypal::Payment::HandleSaleRefunded.(resource)
    when "PAYMENT.SALE.REVERSED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-10]
            Donations::Paypal::Payment::HandleSaleReversed.(resource)
        MESSAGE
      )
      Donations::Paypal::Payment::HandleSaleReversed.(resource)
    when "PAYMENTS.PAYMENT.CREATED"
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::ProcessPaypalUpdate-11]
            Donations::Paypal::Payment::HandlePaymentCreated.(resource)
        MESSAGE
      )
      Donations::Paypal::Payment::HandlePaymentCreated.(resource)
    end
  end
end
