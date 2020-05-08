FactoryBot.define do
  factory :track do
    slug { "slug_#{SecureRandom.hex(4)}" }
    title { 'Ruby' }
  end
end
