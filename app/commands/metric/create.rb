class Metric::Create
  include Mandate

  queue_as :metrics

  def initialize(type, occurred_at, **params)
    @type = type
    @occurred_at = occurred_at
    @request_context = params.delete(:request_context) || {}
    @params = params
  end

  def call
    klass = "metrics/#{type}_metric".camelize.constantize

    klass.new(occurred_at:, params:).tap do |metric|
      if metric.store_country_code?
        metric.country_code = country_code
        metric.country_name = country_name
        metric.coordinates = coordinates
      end
      metric.save!

      MetricsChannel.broadcast!(metric)
    rescue ActiveRecord::RecordNotUnique
      return klass.find_by!(uniqueness_key: metric.uniqueness_key)
    end
  end

  private
  attr_reader :type, :occurred_at, :params, :request_context

  def country_code = request_context[:country_code].presence

  def country_name = Country.name_for(country_code)

  def coordinates = request_context[:coordinates].presence
end
