class Metric::Create
  include Mandate

  queue_as :metrics

  def initialize(type, occurred_at, params)
    @type = type
    @occurred_at = occurred_at
    @request_context = params.delete(:request_context) || {}
    @params = params
  end

  def call
    klass = "metrics/#{type}_metric".camelize.constantize

    klass.new(occurred_at:, params:).tap do |metric|
      metric.country_code = Geocoder.search(remote_ip).first&.country_code if metric.store_country_code? && remote_ip
      metric.save!
    rescue ActiveRecord::RecordNotUnique
      return klass.find_by!(uniqueness_key: metric.uniqueness_key)
    end
  end

  private
  attr_reader :type, :occurred_at, :params, :request_context

  memoize
  def remote_ip = request_context[:remote_ip]
end
