class User::VerifyEmail
  include Mandate

  initialize_with :user

  def call = user.update(email_status:)

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
    response = JSON.parse(RestClient.get(api_url).body, symbolize_names: true)
    response.dig(:results, :result)
  end

  def api_url = "https://api.sparkpost.com/api/v1/recipient-validation/single/#{user.email}"
end
