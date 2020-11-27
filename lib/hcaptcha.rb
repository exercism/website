require "rest_client"

class HCaptcha
  class << self
    attr_accessor :endpoint, :secret, :site_key
  end

  def self.configure
    yield(self)
  end

  def self.verify(response)
    begin
      verification = RestClient.post("#{endpoint}/siteverify", {
                                       secret: secret,
                                       response: response
                                     })
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
