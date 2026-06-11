class User::NotifyJikiOfInsiderChange
  include Mandate

  queue_as :default

  EVENTS = %i[activated deactivated].freeze
  BACKOFF = [1.minute, 5.minutes, 30.minutes, 2.hours, 12.hours].freeze

  initialize_with :user, :event, attempt: 1

  def call
    raise ArgumentError, "Unknown event: #{event}" unless EVENTS.include?(event.to_sym)
    return if webhook_url.blank?

    response = RestClient.post(
      webhook_url,
      body,
      content_type: :json,
      'X-Exercism-Signature' => signature,
      'X-Exercism-Event' => "insider.#{event}"
    )

    return if response.code.between?(200, 299)

    requeue_with_backoff!
  rescue RestClient::ExceptionWithResponse, RestClient::Exception, Errno::ECONNREFUSED, SocketError
    requeue_with_backoff!
  end

  private
  def requeue_with_backoff!
    return if attempt > BACKOFF.length

    wait = BACKOFF[attempt - 1]
    self.class.defer(user, event, attempt: attempt + 1, wait:)
  end

  memoize
  def body
    {
      event: "insider.#{event}",
      exercism_id: user.id,
      occurred_at: Time.current.utc.iso8601
    }.to_json
  end

  def signature
    digest = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      Exercism.secrets.jiki_webhook_secret.to_s,
      body
    )
    "sha256=#{digest}"
  end

  def webhook_url
    Exercism.secrets.jiki_webhook_url
  end
end
