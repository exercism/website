FactoryBot.define do
  factory :site_tag, class: 'Site::Tag' do
    tag { "technique:laziness" }
    description { "very cool" }

    trait :random do
      tag { "construct:#{SecureRandom.compact_uuid}" }
    end
  end
end
