FactoryBot.define do
  factory :metric do
    metric_action { :submit_solution }
    country_code { 'NL' }
    user { create :user }
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end
  end
end
