FactoryBot.define do
  factory :track_trophy, class: 'Track::Trophies::General::MentoredTrophy' do
  end

  factory :general_track_trophy, class: 'Track::Trophies::General::MentoredTrophy' do
  end

  factory :shared_track_trophy, class: 'Track::Trophies::Shared::CompletedLearningMode' do
  end

  %i[
    completed_all_exercises completed_five_difficult_exercises
    completed_twenty_exercises mentored
  ].each do |type|
    factory "#{type}_trophy", class: "Track::Trophies::General::#{type.to_s.camelize}Trophy" do
    end
  end

  %i[
    completed_fifty_percent_of_exercises completed_learning_mode functional
  ].each do |type|
    factory "#{type}_trophy", class: "Track::Trophies::Shared::#{type.to_s.camelize}Trophy" do
    end
  end
end
