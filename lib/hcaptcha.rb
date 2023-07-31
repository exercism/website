require "rest_client"

class HCaptcha
  def self.verify(response)
    begin
      verification = RestClient.post(
        "#{Exercism.config.hcaptcha_endpoint}/siteverify",
        {
          secret: Exercism.secrets.hcaptcha_secret,
          response:
        }
      )
    rescue RestClient::ExceptionWithResponse
      return HCaptcha::Verification.new(success: false)
    end

    verification_body = JSON.parse(verification.body)

    if verification_body["success"]
      HCaptcha::Verification.new(success: true)
    else
      HCaptcha::Verification.new(success: false)
    end
  end

  class Verification
    include Mandate

    initialize_with success: Mandate::NO_DEFAULT

    def succeeded?
      success
    end

    def failed?
      !success
    end
  end
end
