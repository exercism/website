class Cloudflare::PurgeUrls
  include Mandate

  queue_as :background

  initialize_with :urls

  def call
    return if urls.blank?
    return if zone_id.blank?
    return if api_token.blank?

    urls.compact.uniq.each_slice(BATCH_SIZE) { |batch| purge!(batch) }
  end

  private
  def purge!(batch)
    RestClient.post(
      "https://api.cloudflare.com/client/v4/zones/#{zone_id}/purge_cache",
      { files: batch }.to_json,
      authorization: "Bearer #{api_token}",
      content_type: :json,
      accept: :json
    )
  end

  # Both of these live in secrets rather than config as the config
  # keys are owned by the exercism-config gem, which raises NoMethodError
  # for anything it doesn't know about.
  def zone_id = Exercism.secrets.cloudflare_zone_id
  def api_token = Exercism.secrets.cloudflare_api_token

  # Cloudflare's purge-by-URL API accepts a maximum of 100 URLs per request
  BATCH_SIZE = 100
  private_constant :BATCH_SIZE
end
