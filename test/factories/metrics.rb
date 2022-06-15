FactoryBot.define do
  factory :metric do
    action { :submit_solution }
    country_code { 'NL' }
    user { create :user }
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end
  end
end
