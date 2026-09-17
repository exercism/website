class ReactComponents::Insiders::PaymentPending < ReactComponents::ReactComponent
  initialize_with return_to: nil

  def to_s
    super("insiders-payment-pending", {
      endpoint: Exercism::Routes.api_user_path,
      insiders_redirect_path: return_to || Exercism::Routes.insiders_path
    })
  end
end
