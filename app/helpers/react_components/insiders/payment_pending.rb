class ReactComponents::Insiders::PaymentPending < ReactComponents::ReactComponent
  def to_s
    super("insiders-payment-pending", {
      endpoint: Exercism::Routes.api_user_path,
      insiders_redirect_path: Exercism::Routes.insiders_path
    })
  end
end
