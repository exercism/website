FactoryBot.define do
  factory :training_track_tags_tuples, class: 'Training::TrackTagsTuple' do
    track { create :track }
    code { "Hello, World!" }
  end
end
