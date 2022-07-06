class Metric::Create
  include Mandate

  initialize_with :type, :occurred_at, :params

  def call
    klass = "metrics/#{type}_metric".camelize.constantize

    klass.new(occurred_at:, params:).tap do |metric|
      metric.save!
    rescue ActiveRecord::RecordNotUnique
      return klass.find_by!(uniqueness_key: metric.uniqueness_key)
    end
  end
end
