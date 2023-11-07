FactoryBot.define do
  factory :track_tag, class: 'Track::Tag' do
    track { create :track }
  end
end
