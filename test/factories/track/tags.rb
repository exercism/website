FactoryBot.define do
  factory :track_tag, class: 'Track::Tag' do
    track { create :track }
    tag { "construct:#{SecureRandom.compact_uuid}" }
  end
end
