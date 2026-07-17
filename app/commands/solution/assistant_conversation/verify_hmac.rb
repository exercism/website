class Solution::AssistantConversation::VerifyHMAC
  include Mandate

  # The worker signs the response when the stream completes and the client
  # saves it immediately afterwards, so anything older than this is stale
  # (and a replayed signature, not a live conversation).
  MAX_AGE = 10.minutes

  initialize_with :solution, :assistant_message, :timestamp, :signature

  def call
    raise InvalidHMACSignatureError, "Signature timestamp is stale or invalid" unless fresh?

    unless ActiveSupport::SecurityUtils.secure_compare(signature.to_s, expected_signature)
      raise InvalidHMACSignatureError, "HMAC signature verification failed"
    end

    true
  end

  private
  def fresh?
    time = Time.iso8601(timestamp.to_s)
    time > MAX_AGE.ago && time < 1.minute.from_now
  rescue ArgumentError
    false
  end

  def expected_signature
    payload = "#{solution.user_id}:#{solution.uuid}:#{assistant_message}:#{timestamp}"
    OpenSSL::HMAC.hexdigest('SHA256', Exercism.secrets.assistant_chat_hmac_secret, payload)
  end
end
