class Webhooks::ProcessPaypalUpdate
  include Mandate

  initialize_with :payload

  def call
    Webhooks::Paypal::Debug.("PAYLOAD: #{payload}")

    response = RestClient.post('https://ipnpb.paypal.com/cgi-bin/webscr', "cmd=_notify-validate&#{payload}")
    case response.body
    when "VERIFIED"
      Webhooks::Paypal::Debug.("VERIFIED")
      # TODO: handle verified
    when "INVALID"
      Webhooks::Paypal::Debug.("INVALID")
      # TODO: handle invalid
    else
      Webhooks::Paypal::Debug.("UNKNOWN")
    end
  end
end
