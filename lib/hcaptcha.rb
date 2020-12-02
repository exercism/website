require "rest_client"

class HCaptcha
  def self.verify(response)
    begin
      verification = RestClient.post(
        "#{Exercism.config.hcaptcha_endpoint}/siteverify",
        {
          secret: Exercism.secrets.hcaptcha_secret,
          response: response
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
    def initialize(success:)
      @success = success
    end

    def succeeded?
      success
    end

    def failed?
      !success
    end

    private
    attr_reader :success
  end
end
