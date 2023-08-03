FactoryBot.define do
  factory :trophy, class: 'Track::Trophies::General::MentoredTrophy' do
  end

  factory :general_trophy, class: 'Track::Trophies::General::MentoredTrophy' do
  end

  factory :shared_trophy, class: 'Track::Trophies::Shared::CompletedLearningModeTrophy' do
  end

  %i[
    completed_all_exercises completed_fifty_percent_of_exercises
    completed_twenty_exercises mentored iterated_twenty_exercises
    read_fifty_community_solutions
  ].each do |type|
    factory "#{type}_trophy", class: "Track::Trophies::General::#{type.to_s.camelize}Trophy" do
    end
  end

  %i[
    completed_five_hard_exercises completed_learning_mode functional
  ].each do |type|
    factory "#{type}_trophy", class: "Track::Trophies::Shared::#{type.to_s.camelize}Trophy" do
    end
  end
end
