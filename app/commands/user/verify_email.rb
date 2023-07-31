class User::VerifyEmail
  include Mandate

  initialize_with :user

  def call
    return unless user.email_status_unverified?

    user.update!(email_status:)
  end

  private
  def email_status
    case check_email_status!
    when 'valid'
      :verified
    when 'neutral'
      :verified
    else
      :invalid
    end
  end

  memoize
  def check_email_status!
    response = RestClient.get(api_url, authorization: Exercism.secrets.sparkpost_api_key)
    json = JSON.parse(response.body, symbolize_names: true)
    json.dig(:results, :result)
  end

  def api_url = "https://api.sparkpost.com/api/v1/recipient-validation/single/#{user.email}"
end
