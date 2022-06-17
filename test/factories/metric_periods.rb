FactoryBot.define do
  factory :metric_period_month, class: 'MetricPeriod::Month' do
    action { :submit_solution }
    month { SecureRandom.random_number(1..12) }
    count { SecureRandom.random_number(100_000) }
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end
  end

  factory :metric_period_day, class: 'MetricPeriod::Day' do
    action { :submit_solution }
    day { SecureRandom.random_number(1..30) }
    count { SecureRandom.random_number(100_000) }
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end
  end

  factory :metric_period_hour, class: 'MetricPeriod::Hour' do
    action { :submit_solution }
    hour { SecureRandom.random_number(0..23) }
    count { SecureRandom.random_number(100_000) }
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end
  end
end
