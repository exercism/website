class Metric::Create
  include Mandate

  initialize_with :type, :occurred_at, :country_code, :params

  def call
    klass = "metrics/#{type}_metric".camelize.constantize

    klass.new(occurred_at:, country_code:, params:).tap do |metric|
      metric.save!
    rescue ActiveRecord::RecordNotUnique
      return klass.find_by!(uniqueness_key: metric.uniqueness_key)
    end
  end
end
