class Metric::Create
  include Mandate

  initialize_with :type, :occurred_at, :params

  def call
    klass = "metrics/#{type}_metric".camelize.constantize

    klass.new(occurred_at:, country_code:, params: params.except(:remote_ip)).tap do |metric|
      metric.save!
    rescue ActiveRecord::RecordNotUnique
      return klass.find_by!(uniqueness_key: metric.uniqueness_key)
    end
  end

  private
  def country_code = Geocoder.search(params[:remote_ip]).first&.country_code
end
