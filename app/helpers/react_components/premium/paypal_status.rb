class ReactComponents::Premium::PaypalStatus < ReactComponents::ReactComponent
  def to_s = super("premium-paypal-status", { endpoint: Exercism::Routes.api_user_path,
                                              premium_redirect_path: Exercism::Routes.premium_path })
end
