FactoryBot.define do
  factory :metric_period_month, class: 'MetricPeriod::Month' do
    metric_type { Metrics::StartSolutionMetric.class }
    month { SecureRandom.random_number(1..12) }
    count { SecureRandom.random_number(100_000) }
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end
  end

  factory :metric_period_day, class: 'MetricPeriod::Day' do
    metric_type { Metrics::StartSolutionMetric.class }
    day { SecureRandom.random_number(1..30) }
    count { SecureRandom.random_number(100_000) }
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end
  end

  factory :metric_period_minute, class: 'MetricPeriod::Minute' do
    metric_type { Metrics::StartSolutionMetric.class }
    minute { SecureRandom.random_number(0..1439) }
    count { SecureRandom.random_number(100_000) }
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end
  end
end
